defmodule Brood.Resource.Account.Register do
  use PlugRest.Resource
  require Logger

  def allowed_methods(conn, state) do
    Logger.info "test"
    {["PUT"], conn, state}
  end

  def content_types_accepted(conn, state) do
    {[{{"multipart", "form-data", :*}, :from_multipart}], conn, state}
  end

  def from_multipart(conn, state) do
    Logger.info "#{inspect conn.params}"
    {true, conn
      |> put_resp_content_type("application/json")
      |> put_rest_body("{\"success\": \"true\"}"),
    state}
  end

end
