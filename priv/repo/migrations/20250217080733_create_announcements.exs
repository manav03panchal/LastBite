defmodule Lastbite.Repo.Migrations.CreateAnnouncements do
  use Ecto.Migration

  def change do
    create table(:announcements) do
      add :title, :string
      add :content, :text
      add :event_date, :utc_datetime
      add :location, :string
      add :announcement_type, :string
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create index(:announcements, [:user_id])
  end
end
