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
    conn =
      conn
      |> put_rest_body(Poison.encode!(conn.params |> do_query))
    {true, conn, state}
  end

  def do_query(%{"type" => type, "from" => from, "to" => to}) do
    to =
      case to do
        "now" -> "now()"
        _ -> to
    from =
      case from do
        "now" -> "now()"
        _ -> from
      end
    end
    "SELECT * FROM \"brood\".\"realtime\".\"#{type}\" WHERE time > #{to} - #{from}"
    |> Brood.DB.InfluxDB.query()
  end

end
