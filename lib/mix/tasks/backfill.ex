defmodule Mix.Tasks.BackFill do
  use Mix.Task
  use Timex
  require Logger

  @backfill_days 30

  def run(_args) do
    Application.ensure_all_started(:timex)
    Application.ensure_all_started(:instream)
    Application.ensure_all_started(:poolboy)
    Supervisor.start_link([Brood.DB.InfluxDB.child_spec], strategy: :one_for_one)
    IO.puts "Running: Filling InfluxDB..."
    random("ieq.co2", 400, 1200)
    random("ieq.voc", 0, 300)
    random("ieq.pm", 0, 60)
    random("hvac.temperature", 65, 72)
    random("weather_station.outdoor_temperature", -3, 60)
    random("weather_station.humidity", 20, 100)
    random("weather_station.solar.radiation", 0, 500)
    random("weather_station.wind.speed", 0, 7)
    random("smart_meter.kw_delivered", 1, 9)
    Mix.shell.info "InfluxDB has been filled!"
  end

  def write(points) do
    Logger.info "#{inspect points}"
    points |> Brood.DB.InfluxDB.write_points
  end

  def random(datapoint, start, range) do
    total = @backfill_days * 24 * 60
    start_date = Timex.now() |> Timex.shift(days: -@backfill_days)
    0..total |> Enum.map(fn(i) ->
      date_str = Timex.shift(start_date, minutes: i)
      timestamp = DateTime.to_unix(Timex.to_datetime(date_str), :milliseconds)
      point = %{
        measurement: "#{datapoint}",
        timestamp: (timestamp * 1000000),
        fields: %{
          value: Enum.random(start..range)
        },
        tags: %{
          node_id: "00000000fdf4ffe2",
          id: nil,
          type: nil,
          zipcode: nil,
          climate_zone: nil
        }
      }
    end)
    |> write()
    IO.puts "Added data for #{datapoint}"
  end
end
