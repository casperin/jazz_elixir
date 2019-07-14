defmodule Jazz.Repo do
  use Ecto.Repo,
    otp_app: :jazz,
    adapter: Ecto.Adapters.Postgres
end
