defmodule Lastbite.Sharing do
  import Ecto.Query
  alias Lastbite.Repo
  alias Lastbite.Sharing.FoodItem

  def list_available_food_items do
    now = DateTime.utc_now()

    FoodItem
    |> where([f], f.expires_at > ^now and f.claimed == false)
    |> order_by([f], asc: f.expires_at)
    |> Repo.all()
  end

  def create_food_item(attrs \\ %{}) do
    %FoodItem{}
    |> FoodItem.changeset(attrs)
    |> Repo.insert()
  end

  def claim_food_item(id) do
    food_item = Repo.get!(FoodItem, id)

    food_item
    |> FoodItem.changeset(%{claimed: true})
    |> Repo.update()
  end
end
