defmodule Brood.Resource.Account.Login do
  use PlugRest.Resource
  require Logger

  def allowed_methods(conn, state) do
    {["POST"], conn, state}
  end

  def content_types_provided(conn, state) do
    {[{"application/json", :to_json}], conn, state}
  end

  def content_types_accepted(conn, state) do
    {[{"multipart/form-data", :from_multipart}], conn, state}
  end

  def from_multipart(conn, state) do
    Logger.info "#{inspect conn.params}"
    conn = put_resp_content_type(conn, "application/json")
    {true, conn, state}
  end

  def to_json(conn, state) do
    {"{\"success\": \"true\"}", conn, state}
  end

end
