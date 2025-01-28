defmodule TodoIst.Guardian do
  use Guardian, otp_app: :todo_ist, key: :el_auth_token
  alias TodoIst.Accounts.User
  require Logger
  # def build_claims(_claims, _resource, _opts) do
  #   IO.puts("calling for build claims")
  #   {:ok, ""}
  # end

  # def verify_claims(_claims, _options) do
  #   IO.puts("calling for verification")
  #   {:ok, ""}
  # end

  # def on_verify(_claims, _token, _options) do
  #   IO.puts("calling for verification")
  #   {:ok, ""}
  # end

  def subject_for_token(%{id: id}, _claims) do
    Logger.warning("Called SUBJECT FOR TOKEN")
    sub = to_string(id)
    {:ok, sub}
  end

  def subject_for_token(_, _) do
    Logger.warning("Invalid token found")
    {:error, "Invalid subject for guardian subject id"}
  end

  def resource_from_claims(%{"sub" => id}) do
    IO.puts("CALLED RESOURCE FROM CLAIMS WITH ID: #{id}")

    case User.get_user_by_id(id) do
      {:ok, user} ->
        {:ok, user}

      {:error, reason} ->
        IO.puts("RESOURCE NOT FOUND: #{inspect(reason)}")
        {:error, :resource_not_found}
    end
  end

  def resource_from_claims(_claims) do
    {:error, :invalid_claims}
  end

  # def build_claims(claims, _, _) do
  #   IO.puts(inspect(claims))
  #   IO.puts("CALLING BUILD CLAIMS!!")
  #   {:ok, claims}
  # end
end
