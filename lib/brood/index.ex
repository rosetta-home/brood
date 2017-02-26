defmodule Brood.Index do
  require Logger

  @influx_database Application.get_env(:brood, :influx_database)
  @keys Application.get_env(:brood, :keys)

  defmodule State do
    defstruct hostname: nil
  end

  def init({:ssl, :http}, req, opts) do
    {:ok, req, %State{}}
  end

  def handle(req, state) do
    headers = [
        {"cache-control", "no-cache"},
        {"connection", "close"},
        {"content-type", "text/plain"},
        {"expires", "Mon, 3 Jan 2000 12:34:56 GMT"},
        {"pragma", "no-cache"}
    ]
    {:ok, body, req2} = req |> :cowboy_req.body
    Logger.info body
    Task.Supervisor.start_child(Brood.TaskSupervisor, fn -> body |> process end)
    {:ok, req3} = :cowboy_req.reply(200, headers, "ok", req2)
    {:ok, req3, state}
  end

  def process(data) do
    data |> parse |> write
  end

  def parse(data) do
    data |> Poison.decode!
  end

  def write(data) do
    tags = %{node_id: data |> Map.get("id")}
    timestamp = :os.system_time(:nano_seconds)
    points = Enum.flat_map(@keys, fn({k, v}) ->
      key = Atom.to_string(k)
      devices = get_in(data, ["data", key])
      Enum.flat_map(devices, fn(device) ->
        tags = Enum.reduce(v.tags, tags, fn(tag, acc) ->
          Map.put(acc, String.to_atom(tag), get_in(device, [tag]))
        end)
        Enum.map(v.values, fn(value) ->
          v = case get_in(device, value) do
            a when a |> is_number -> a/1
            _ -> 0.0
          end
          %{
            measurement: "#{key}.#{Enum.join(value, ".")}",
            timestamp: timestamp,
            fields: %{
              value: v
            },
            tags: tags
          }
        end)
      end)
    end)
    Logger.info "#{inspect points}"
    points |> Brood.DB.InfluxDB.write_points
  end

  def terminate(_reason, req, state), do: :ok

end
