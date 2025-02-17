defmodule Lastbite.Community.Announcement do
  use Ecto.Schema
  import Ecto.Changeset

  schema "announcements" do
    field :title, :string
    field :content, :string
    field :event_date, :utc_datetime
    field :location, :string
    # "sale", "charity_food", "charity_event"
    field :announcement_type, :string
    belongs_to :user, Lastbite.Accounts.User

    timestamps()
  end

  def changeset(announcement, attrs) do
    announcement
    |> cast(attrs, [:title, :content, :event_date, :location, :announcement_type, :user_id])
    |> validate_required([:title, :content, :event_date, :location, :announcement_type, :user_id])
    |> validate_inclusion(:announcement_type, ["sale", "charity_food", "charity_event"])
  end
end
