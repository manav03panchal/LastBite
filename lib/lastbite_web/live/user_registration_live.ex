defmodule LastbiteWeb.UserRegistrationLive do
  use LastbiteWeb, :live_view

  alias Lastbite.Accounts
  alias Lastbite.Accounts.User

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm py-16">
      <div class="text-center mb-8">
        <h1 class="text-2xl font-bold text-gray-900 mb-2">Register for an account</h1>
        <p class="text-sm text-gray-500">
          Already registered?
          <.link navigate={~p"/users/log_in"} class="text-green-600 hover:text-green-700">
            Log in
          </.link>
          to your account now.
        </p>
      </div>

      <.simple_form
        for={@form}
        id="registration_form"
        phx-submit="save"
        phx-change="validate"
        phx-trigger-action={@trigger_submit}
        action={~p"/users/log_in?_action=registered"}
        method="post"
        class="bg-white p-6 rounded-lg shadow-sm"
      >
        <.error :if={@check_errors} class="mb-4 p-3 rounded bg-red-50 text-red-700 text-sm">
          Oops, something went wrong! Please check the errors below.
        </.error>

        <.input field={@form[:email]} type="email" label="Email" required />
        <.input field={@form[:password]} type="password" label="Password" required />

        <:actions>
          <.button
            phx-disable-with="Creating account..."
            class="w-full bg-green-600 hover:bg-green-700"
          >
            Create an account
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        changeset = Accounts.change_user_registration(user)
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
