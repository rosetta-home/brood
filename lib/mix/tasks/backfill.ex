defmodule Mix.Tasks.BackFill do
  use Mix.Task
  use Timex
  require Logger

  @shortdoc "Backfill data for development"
  @moduledoc """
  Backfill data for development
  """
  def run(_args) do
    Application.ensure_all_started(:timex)
    Application.ensure_all_started(:instream)
    Application.ensure_all_started(:poolboy)
    Supervisor.start_link([Brood.DB.InfluxDB.child_spec], strategy: :one_for_one)
    IO.puts "Running: Filling InfluxDB..."
    random("ieq.co2",400,1200)
    Mix.shell.info "InfluxDB has been filled!"
  end

  def loop(body, starting_value \\ nil) when is_function(body) do
    try do
      iteration_result = body.(starting_value)
      loop(body, iteration_result)
    catch
      thrown_result -> thrown_result
    end
  end

  def write(points) do
    Logger.info "#{inspect points}"
    [points] |> Brood.DB.InfluxDB.write_points
  end

  def random(datapoint,begin,start) do
    days = 1
    counts = (days * 24) * 60
    datetime = Timex.now
    loop(fn x ->
      if x > counts, do: throw "Done"
      date_str = Timex.shift(datetime, minutes: -x)
      timestamp = DateTime.to_unix(Timex.to_datetime(date_str), :milliseconds)
      # Create data point with given timestampe
      point = %{
          measurement: "#{datapoint}",
          timestamp: (timestamp * 1000000),
          fields: %{
            value: Enum.random(begin..start)
          },
          tags: %{
            node_id: nil,
            id: nil,
            type: nil,
            zipcode: nil,
            climate_zone: nil
          }
        }
      write(point)
      x + 1
    end, 1)

    IO.puts "Added data for #{datapoint}"
  end

end
