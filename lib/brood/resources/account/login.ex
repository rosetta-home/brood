defmodule Brood.Resource.Account.Login do
  use PlugRest.Resource
  alias Brood.Resource.Account
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
    do: respond("{\"success\": \"#{id}\"}", conn, state)
  end

  def respond(data, conn, state) do
    {true, conn
      |> put_resp_content_type("application/json")
      |> put_rest_body(data),
    state}
  end

end
