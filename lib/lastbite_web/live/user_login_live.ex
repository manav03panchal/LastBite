defmodule LastbiteWeb.UserLoginLive do
  use LastbiteWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm py-16">
      <div class="text-center mb-8">
        <h1 class="text-2xl font-bold text-gray-900 mb-2">Log in to account</h1>
        <p class="text-sm text-gray-500">
          Don't have an account?
          <.link navigate={~p"/users/register"} class="text-green-600 hover:text-green-700">
            Sign up
          </.link>
          for an account now.
        </p>
      </div>

      <.simple_form
        for={@form}
        id="login_form"
        action={~p"/users/log_in"}
        phx-update="ignore"
        class="bg-white p-6 rounded-lg shadow-sm"
      >
        <.input field={@form[:email]} type="email" label="Email" required />
        <.input field={@form[:password]} type="password" label="Password" required />

        <div class="flex items-center justify-between mt-4 mb-6">
          <div class="flex items-center">
            <.input field={@form[:remember_me]} type="checkbox" label="Keep me logged in" />
          </div>
          <.link href={~p"/users/reset_password"} class="text-sm text-green-600 hover:text-green-700">
            Forgot your password?
          </.link>
        </div>

        <:actions>
          <.button phx-disable-with="Logging in..." class="w-full bg-green-600 hover:bg-green-700">
            Log in <span aria-hidden="true">→</span>
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
