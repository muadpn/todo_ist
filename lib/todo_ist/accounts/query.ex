defmodule TodoIst.Accounts.Query do
  alias TodoIst.Repo
  import Ecto.Query

  @doc """
  This function accept a string and list out 5 users matching the string.
  else will return {:error, message}
  """
  def fetch_users_by_email(email) when is_binary(email) do
    query =
      from u in "users",
        where: ilike(u.email, ^"%#{email}%"),
        limit: 5,
        select: %{
          id: type(u.id, :binary_id),
          email: u.email,
          name: u.name,
          inserted_at: u.inserted_at
        }

    Repo.all(query)
  end

  def fetch_users_by_email(_) do
    {:error, "Didn't find the user you are looking for...."}
  end
end
