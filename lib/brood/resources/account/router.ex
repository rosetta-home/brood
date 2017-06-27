defmodule Brood.Resource.Account.Router do
  use PlugRest.Router
  alias Brood.Resource.Account
  require Logger

  plug Plug.Parsers, parsers: [:multipart]
  plug :match
  plug :dispatch

  resource "/register", Account.Register
  resource "/login", Account.Login

end
