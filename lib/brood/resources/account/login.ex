defmodule Brood.Resource.Account.Login do
  use PlugRest.Resource
  alias Brood.Resource.Account
  alias Brood.Resource.Account.Router
  require Logger

  def allowed_methods(conn, state) do
    {["POST"], conn, state}
  end

  def content_types_accepted(conn, state) do
    {[{{"multipart", "form-data", :*}, :from_multipart}], conn, state}
  end

  def from_multipart(conn, state) do
    with %Account{} = auth <- conn.params |> Account.parse_params,
      %Account{} = account <- auth |> Account.authenticate,
      id <- account._id |> BSON.ObjectId.encode!,
    do:
      conn
      |> Router.sign(account)
      |> Router.response_body
      |> Router.respond(state)
  end

end
