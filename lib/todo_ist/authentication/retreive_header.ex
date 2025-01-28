defmodule TodoIst.Authentication.RetreiveHeader do
  # import Plug.Conn

  # @locales ["en", "fr", "de"]

  def init(default), do: default

  def call(conn, _) do
    %Plug.Conn{cookies: cookies} = conn
    # %Plug.Conn{req_cookies: %{"el_auth_token" => cookies}} =
    IO.inspect(cookies)
    conn
    # assign(conn, :el_auth_token, cookies)
  end

  # def call(conn, _) do
  #   conn
  # end
end
