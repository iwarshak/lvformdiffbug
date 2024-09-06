defmodule Lvbug.Repo do
  use Ecto.Repo,
    otp_app: :lvbug,
    adapter: Ecto.Adapters.SQLite3
end
