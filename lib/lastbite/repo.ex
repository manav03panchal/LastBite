defmodule Lastbite.Repo do
  use Ecto.Repo,
    otp_app: :lastbite,
    adapter: Ecto.Adapters.Postgres
end
