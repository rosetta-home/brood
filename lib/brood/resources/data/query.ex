defmodule Brood.Resource.Data.Query do
  use PlugRest.Resource
  require Logger

  @max_microseconds 2629800000000
  @max_seconds 2629800
  @max_minutes 43830
  @max_hours 730
  @max_days 30
  @max_weeks 4

  def allowed_methods(conn, state) do
    {["HEAD", "OPTIONS", "POST"], conn, state}
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

  def do_query(%{"type" => type, "from" => from, "to" => to} = params) do
    group_by_time = params |> Map.get("group_by_time", "1m")
    from = from |> parse_time
    to = to |> parse_time
    "SELECT MEAN(value) FROM \"brood\".\"realtime\".\"#{type}\" WHERE node_id='0000000081474d35' AND time > #{to} - #{from} GROUP BY time(#{group_by_time}) fill(previous)"
    |> Brood.DB.InfluxDB.query()
  end

  def parse_time(time) do
    case Integer.parse(time) do
      {int, "u"} -> (int |> get_max(@max_microseconds)) <> "u"
      {int, "s"} -> (int |> get_max(@max_seconds)) <> "s"
      {int, "m"} -> (int |> get_max(@max_minutes)) <> "m"
      {int, "h"} -> (int |> get_max(@max_hours)) <> "h"
      {int, "d"} -> (int |> get_max(@max_days)) <> "d"
      {int, "w"} -> (int |> get_max(@max_weeks)) <> "w"
      :error ->
        case time do
          _ -> "now()"
        end
    end
  end

  def get_max(n, limit) do
    case n > limit do
      true -> limit |> Integer.to_string
      false -> n |> Integer.to_string
    end
  end

end
