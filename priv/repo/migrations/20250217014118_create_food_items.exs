defmodule Lastbite.Repo.Migrations.CreateFoodItems do
  use Ecto.Migration

  def change do
    create table(:food_items) do
      add :name, :string
      add :business, :string
      add :quantity, :string
      add :location, :string
      add :expires_at, :utc_datetime
      add :claimed, :boolean, default: false

      timestamps()
    end
  end
end

