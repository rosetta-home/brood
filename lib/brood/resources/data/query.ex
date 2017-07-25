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
    {["GET"], conn, state}
  end

  def content_types_provided(conn, state) do
    {[{{"application", "json", :*}, :to_json}], conn, state}
  end

  def to_json(conn, state) do
    account = Guardian.Plug.current_resource(conn)
    #TODO get node_id from account
    node_id = "0000000081474d35"
    body =
      conn.params
      |> get_query(node_id)
      |> Brood.DB.InfluxDB.query()
      |> Poison.encode!()
    {true, conn |> put_rest_body(body), state}
  end

  defp get_query(%{"aggregator" => agg, "measurement" => measurement, "tag" => tag, "value" => value, "from" => from, "to" => to, "bucket" => bucket}, node) do
    build_query(node, agg, measurement, from, to, bucket, tag, value)
  end

  defp get_query(%{"aggregator" => agg, "measurement" => measurement, "tag" => tag, "value" => value, "from" => from, "to" => to}, node) do
    build_query(node, agg, measurement, from, to, "1m", tag, value)
  end

  defp get_query(%{"aggregator" => agg, "measurement" => measurement, "from" => from, "to" => to, "bucket" => bucket}, node) do
    build_query(node, agg, measurement, from, to, bucket)
  end

  defp get_query(%{"aggregator" => agg, "measurement" => measurement, "from" => from, "to" => to}, node) do
    build_query(node, agg, measurement, from, to)
  end

  defp build_query(node, agg, measurement, from, to, bucket \\ "1m", tag \\ nil, value \\ nil) do
    """
    SELECT #{agg |> aggregator()}
    FROM \"brood\".\"realtime\".\"#{measurement}\"
    WHERE node_id='#{node}'
    #{{tag, value} |> tags()}
    AND time >= #{from |> parse_time}
    AND time <= #{to |> parse_time}
    GROUP BY time(#{bucket}) fill(null)
    """
  end

  defp aggregator("mean"), do: "MEAN(value)"
  defp aggregator("count"), do: "COUNT(value)"
  defp aggregator("sum"), do: "SUM(value)"
  defp aggregator("min"), do: "MIN(value)"
  defp aggregator("max"), do: "MAX(value)"
  defp aggregator("median"), do: "MEDIAN(median)"
  defp aggregator("first"), do: "FIRST(median)"
  defp aggregator("last"), do: "LAST(median)"
  defp aggregator("percentile99"), do: "PERCENTILE(\"value\", 99)"
  defp aggregator("percentile95"), do: "PERCENTILE(\"value\", 95)"
  defp aggregator("percentile75"), do: "PERCENTILE(\"value\", 75)"
  defp aggregator("percentile50"), do: "PERCENTILE(\"value\", 50)"

  defp tags({tag, value}) do
    case tag do
      nil -> ""
      tag -> "AND #{tag} = '#{value}'"
    end
  end

  defp parse_time(time) do
    case time |> String.ends_with?("Z") do
      true -> "'#{time}'"
      _ ->
        case Integer.parse(time) do
          {int, "u"} -> (int |> get_max(@max_microseconds)) <> "u"
          {int, "s"} -> (int |> get_max(@max_seconds)) <> "s"
          {int, "m"} -> (int |> get_max(@max_minutes)) <> "m"
          {int, "h"} -> (int |> get_max(@max_hours)) <> "h"
          {int, "d"} -> (int |> get_max(@max_days)) <> "d"
          {int, "w"} -> (int |> get_max(@max_weeks)) <> "w"
          :error -> "now()"
        end
    end
  end

  defp get_max(n, limit) do
    case n > limit do
      true -> limit |> Integer.to_string
      false -> n |> Integer.to_string
    end
  end

end
