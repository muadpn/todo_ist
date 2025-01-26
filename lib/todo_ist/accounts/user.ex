defmodule TodoIst.Accounts.User do
  alias TodoIst.{User, Repo}

  def get_user_by_id(id) when is_binary(id) do
    Repo.get_by(User, %{id: id})
    |> user_transformer()
  end

  def get_user_by_id(_) do
    {:error, "Invalid id"}
  end

  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, %{email: email})
  end

  defp user_transformer(user_data) do
    case user_data do
      nil ->
        {:error, "User not found"}

      %User{id: id, email: email, name: name, inserted_at: created_at} ->
        {:ok, %{id: id, email: email, name: name, created_at: created_at}}

      _ ->
        {:error, "User not found, Please try again"}
    end
  end
end
