defmodule Lastbite.Repo.Migrations.AddImageUrlToFoodItems do
  use Ecto.Migration

  def change do
    alter table(:food_items) do
      add :image_url, :string
    end
  end
end

