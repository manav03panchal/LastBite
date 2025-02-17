defmodule Lastbite.Sharing.FoodItem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "food_items" do
    field :name, :string
    field :business, :string
    field :quantity, :string
    field :location, :string
    field :expires_at, :utc_datetime
    field :claimed, :boolean, default: false
    field :image_url, :string
    timestamps()
  end

  def changeset(food_item, attrs) do
    food_item
    # Added image_url here
    |> cast(attrs, [:name, :business, :quantity, :location, :expires_at, :claimed, :image_url])
    |> validate_required([:name, :business, :quantity, :location, :expires_at])
  end
end

