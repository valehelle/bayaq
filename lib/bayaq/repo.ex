defmodule Bayaq.Repo do
  use Ecto.Repo,
    otp_app: :bayaq,
    adapter: Ecto.Adapters.Postgres
end
