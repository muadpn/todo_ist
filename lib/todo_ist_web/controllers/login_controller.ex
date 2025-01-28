defmodule TodoIstWeb.LoginController do
  use TodoIstWeb, :controller
  require Logger
  alias TodoIst.{User, Repo, Guardian}

  def login(conn, %{"email" => email, "password" => password}) do
    case Repo.get_by(User, email: email) do
      nil ->
        send_resp(conn, 404, Jason.encode!(%{error: "Invalid credentials"}))

      user ->
        if Bcrypt.verify_pass(password, user.hashed_password) do
          %{email: email, name: name, id: id} = user

          conn
          |> Guardian.Plug.sign_in(
            %{id: id},
            %{
              data: %{id: id, email: email, name: name}
            }
          )
          |> Guardian.Plug.remember_me(
            %{id: id},
            %{
              data: %{id: id, email: email, name: name}
            },
            key: :el_auth_token
          )
          |> put_resp_content_type("application/json")
          |> send_resp(
            302,
            Jason.encode!(%{redirect: true, redirect_to: "/dashboard", origin: nil})
          )
        else
          conn
          |> send_resp(404, Jason.encode!(%{error: "Invalid credentials"}))
        end
    end
  rescue
    x ->
      IO.puts(inspect(x))
      send_resp(conn, 500, Jason.encode!(%{error: "Invalid credentials"}))
  end

  def login(conn, _) do
    send_resp(conn, 404, Jason.encode!(%{error: "Invalid inputs, Please try again"}))
  end

  def signup(conn, %{"email" => email, "password" => password})
      when is_binary(email) and is_binary(password) do
    case(
      Repo.insert(
        User.registration_changeset(%User{}, %{
          email: email,
          password: password
        }),
        on_conflict: :nothing
      )
    ) do
      {:ok, _user} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!(%{message: "User created successfully"}))

      {:error, changeset} ->
        send_resp(conn, 402, Jason.encode!(changeset.errors))
    end

    json(conn, %{success: 200})
  end

  def signup(conn, _) do
    send_resp(
      conn,
      404,
      Jason.encode!(%{error: "Invalid inputs, Please try again email and Password are required."})
    )
  end
end
