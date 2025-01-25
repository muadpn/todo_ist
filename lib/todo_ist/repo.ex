defmodule TodoIst.Repo do
  use Ecto.Repo,
    otp_app: :todo_ist,
    adapter: Ecto.Adapters.Postgres
end
