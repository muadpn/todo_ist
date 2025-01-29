# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     TodoIst.Repo.insert!(%TodoIst.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias TodoIst.{Repo, User}
alias Bcrypt

defmodule TodoIst.Seeds do
  @domains ["example.com", "mail.com", "test.com", "random.org", "sample.net"]

  def generate_random_email do
    local_part = :crypto.strong_rand_bytes(5) |> Base.encode64() |> String.replace(~r/[^a-zA-Z0-9]/, "")
    domain = Enum.random(@domains)
    "#{local_part}@#{domain}"
  end

  def seed_users do
    1..15
    |> Enum.each(fn _ ->
      email = generate_random_email()
      hashed_password = Bcrypt.hash_pwd_salt(email)

      user_data = %{
        email: email,
        password: email
      }

      changeset = User.registration_changeset(%User{}, user_data)

      case Repo.insert(changeset, on_conflict: :nothing) do
        {:ok, _user} ->
          IO.puts("User created: #{email}")

        {:error, changeset} ->
          IO.inspect(changeset.errors, label: "Error inserting user #{email}")
      end
    end)
  end
end

# Run the seed generation
TodoIst.Seeds.seed_users()
