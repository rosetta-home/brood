defmodule Brood.Resource.Account.Register do
  use PlugRest.Resource
  alias Brood.Resource.Account
  alias Brood.Resource.Account.Router
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
      account <- Account.from_id(result.inserted_id)
    do
      conn
      |> Router.sign(account)
      |> Router.response_body(account |> Account.cleanse)
      |> Router.respond(state)
    else
       {:error, %Mongo.Error{code: 11000}} -> :email_taken
    end

  end

end
