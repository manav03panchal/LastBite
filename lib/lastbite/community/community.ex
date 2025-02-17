defmodule Lastbite.Community do
  import Ecto.Query
  alias Lastbite.Repo
  alias Lastbite.Community.Announcement

  def list_announcements do
    Announcement
    |> order_by([a], desc: a.inserted_at)
    |> preload(:user)
    |> Repo.all()
  end

  def create_announcement(attrs \\ %{}) do
    %Announcement{}
    |> Announcement.changeset(attrs)
    |> Repo.insert()
  end

  def get_announcement!(id) do
    Announcement
    |> preload(:user)
    |> Repo.get!(id)
  end

  def update_announcement(%Announcement{} = announcement, attrs) do
    announcement
    |> Announcement.changeset(attrs)
    |> Repo.update()
  end

  def delete_announcement(%Announcement{} = announcement) do
    Repo.delete(announcement)
  end
end
