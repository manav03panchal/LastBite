defmodule LastbiteWeb.CommunityLive do
  use LastbiteWeb, :live_view
  alias Lastbite.Community
  alias Lastbite.Community.Announcement
  on_mount {LastbiteWeb.UserAuth, :mount_current_user}

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:announcements, Community.list_announcements())
     |> assign(:show_form, false)
     |> assign(:form, to_form(Announcement.changeset(%Announcement{}, %{})))}
  end

  def handle_event("show-form", _, socket) do
    {:noreply, assign(socket, :show_form, true)}
  end

  def handle_event("save", %{"announcement" => params}, socket) do
    params = Map.put(params, "user_id", socket.assigns.current_user.id)

    case Community.create_announcement(params) do
      {:ok, _announcement} ->
        {:noreply,
         socket
         |> assign(:announcements, Community.list_announcements())
         |> assign(:show_form, false)
         |> put_flash(:info, "Announcement posted successfully!")}

      {:error, changeset} ->
        {:noreply,
         socket
         |> assign(:form, to_form(changeset))}
    end
  end
end
