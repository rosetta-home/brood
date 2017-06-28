defmodule Brood.Resource.Account.Register do
  use PlugRest.Resource
  alias Brood.Resource.Account
  require Logger

  def allowed_methods(conn, state) do
    {["PUT"], conn, state}
  end

  def content_types_accepted(conn, state) do
    {[{{"multipart", "form-data", :*}, :from_multipart}], conn, state}
  end

  def from_multipart(conn, state) do
    with %Account{} = account <- conn.params |> Account.parse_params,
      {:ok, %Mongo.InsertOneResult{} = result} <- account |> Account.register(conn.params["password_conf"]),
      id <- result.inserted_id |> BSON.ObjectId.encode!,
    do: respond(id, conn, state)
  end

  def respond(id, conn, state) do
    {true, conn
      |> put_resp_content_type("application/json")
      |> put_rest_body("{\"success\": \"#{id}\"}"),
    state}
  end

end
