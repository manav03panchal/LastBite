defmodule LastbiteWeb.Router do
  use LastbiteWeb, :router
  import LastbiteWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {LastbiteWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Public routes
  scope "/", LastbiteWeb do
    pipe_through [:browser]

    # Landing page
    live "/", HomeLive
    # Public feed for viewing
    live "/feed", FoodShareLive

    # Combine both current_user live_sessions here
    live_session :current_user,
      on_mount: [{LastbiteWeb.UserAuth, :mount_current_user}] do
      live "/community", CommunityLive
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end

  # Protected routes
  scope "/", LastbiteWeb do
    pipe_through [:browser, :require_authenticated_user]
    # Protected route for sharing
    live "/share", FoodShareLive
  end

  # Authentication routes
  scope "/", LastbiteWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{LastbiteWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", LastbiteWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{LastbiteWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", LastbiteWeb do
    pipe_through [:browser]
    delete "/users/log_out", UserSessionController, :delete
  end

  # Development routes
  if Application.compile_env(:lastbite, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: LastbiteWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end

