defmodule TodoIstWeb.LoginController do
  use TodoIstWeb, :controller

  def login(conn, data) do
    IO.puts(inspect(data))
    json(conn, %{success: 200})
  end

  def signup(conn, data) do
    IO.puts(inspect(data))
    json(conn, %{success: 200})
  end
end
