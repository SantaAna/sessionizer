defmodule Sessionizer.Repo do
  use Ecto.Repo,
    otp_app: :sessionizer,
    adapter: Ecto.Adapters.Postgres
end
