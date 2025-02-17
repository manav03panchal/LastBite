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

  def list_my_claim_requests(user_id) do
    FoodItem
    |> where(
      [f],
      f.claim_requested_by_id == ^user_id and f.claimed == false and
        not is_nil(f.claim_requested_at)
    )
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

  def request_claim(id, user) do
    food_item = Repo.get!(FoodItem, id)

    changeset =
      food_item
      |> FoodItem.changeset(%{
        claim_requested_by_id: user.id,
        claim_requested_at: DateTime.utc_now()
      })

    Repo.update(changeset)
  end

  def approve_claim(id) do
    food_item = Repo.get!(FoodItem, id)

    changeset =
      food_item
      |> FoodItem.changeset(%{claimed: true})

    Repo.update(changeset)
  end

  def reject_claim(id) do
    food_item = Repo.get!(FoodItem, id)

    changeset =
      food_item
      |> FoodItem.changeset(%{claim_requested_by_id: nil, claim_requested_at: nil})

    Repo.update(changeset)
  end
end
