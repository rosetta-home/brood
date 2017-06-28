defmodule Brood.Resource.Data.Query do
  use PlugRest.Resource
  require Logger

  def allowed_methods(conn, state) do
    {["POST"], conn, state}
  end

  def content_types_accepted(conn, state) do
    {[{{"application", "json", :*}, :from_json}], conn, state}
  end

  def from_json(conn, state) do
    account = Guardian.Plug.current_resource(conn)
    Logger.info("#{inspect account}")
    Logger.info("#{inspect conn.params}")
    #Query InfluxDB
    {true, conn, state}
  end

end
