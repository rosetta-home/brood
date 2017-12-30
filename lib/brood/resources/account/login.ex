defmodule Brood.Resource.Account.Login do
  use PlugRest.Resource
  alias Brood.Resource.Account
  alias Brood.Resource.Account.Router
  require Logger

  def allowed_methods(conn, state) do
    {["POST"], conn, state}
  end

  def content_types_accepted(conn, state) do
    {[{{"application", "x-www-form-urlencoded", :*}, :from_form}], conn, state}
  end

  def from_form(conn, state) do
    with %Account{} = auth <- conn.params |> Account.parse_params,
      %Account{} = account <- auth |> Account.authenticate,
    do:
      conn
      |> Router.sign(account)
      |> Router.response_body(account |> Account.cleanse)
      |> Router.respond(state)
  end

end
