defmodule Brood.HTTPRouter do
  use Plug.Router
  alias Brood.Resource.Account

  plug :match
  plug :dispatch

  forward "/account", to: Account.Router

end
