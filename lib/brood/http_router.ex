defmodule Brood.HTTPRouter do
  use Plug.Router
  alias Brood.Resource.Account
  alias Brood.Resource.Data
  alias Brood.Resource.WebSocket

  plug :match
  plug :dispatch

  @measurements [
    "ieq.co2",
    "ieq.voc",
    "ieq.pm",
    "hvac.temperature",
    "weather_station.outdoor_temperature",
    "weather_station.humidity",
    "weather_station.solar.radiation",
    "weather_station.wind.speed",
    "smart_meter.kw_delivered",
  ]

  forward "/account", to: Account.Router
  forward "/data", to: Data.Router

  get "/compilation" do
    data =
      @measurements |> Enum.reduce(%{}, fn(m, acc) ->
        acc |> Map.put(m, m |> get_data())
      end)
    template_dir = :code.priv_dir(:brood)
    doc = EEx.eval_file("#{template_dir}/compilation.html.eex", [data: data])
    conn
    |> put_resp_header("content-type", "text/html; charset=utf-8")
    |> send_resp(200, doc)
  end

  get "/connectory" do
    data =
      @measurements |> Enum.reduce(%{}, fn(m, acc) ->
        acc |> Map.put(m, m |> get_data())
      end)
    template_dir = :code.priv_dir(:brood)
    doc = EEx.eval_file("#{template_dir}/connectory.html.eex", [data: data])
    conn
    |> put_resp_header("content-type", "text/html; charset=utf-8")
    |> send_resp(200, doc)
  end

  get "/connectory_3d" do
    data =
      @measurements |> Enum.reduce(%{}, fn(m, acc) ->
        acc |> Map.put(m, m |> get_data())
      end)
    template_dir = :code.priv_dir(:brood)
    doc = EEx.eval_file("#{template_dir}/connectory_3d.html.eex", [data: data])
    conn
    |> put_resp_header("content-type", "text/html; charset=utf-8")
    |> send_resp(200, doc)
  end

  get "/visualization" do
    template_dir = :code.priv_dir(:brood)
    doc = EEx.eval_file("#{template_dir}/visualizations.html.eex", [])
    conn
    |> put_resp_header("content-type", "text/html; charset=utf-8")
    |> send_resp(200, doc)
  end

  def get_data(measurement) do
    node = "00000000fdf4ffe2"
    "SELECT MEAN(value) as value FROM \"brood\".\"realtime\".\"#{measurement}\" WHERE node_id = '#{node}' AND time > now()-30d GROUP BY time(6h) fill(previous)"
    |> Brood.DB.InfluxDB.query()
  end

end
