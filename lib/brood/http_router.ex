defmodule Brood.HTTPRouter do
  use Plug.Router
  alias Brood.Resource.Account
  alias Brood.Resource.Data
  alias Brood.Resource.WebSocket

  plug :match
  plug :dispatch

  forward "/account", to: Account.Router
  forward "/data", to: Data.Router

end
