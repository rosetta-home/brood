defmodule Brood.MQTTHandler do
  use GenMQTT
  alias Brood.SatoriPublisher
  require Logger

  @host Application.get_env(:brood, :mqtt_host)
  @port Application.get_env(:brood, :mqtt_port)

  def start_link do
    client = Node.self |> Atom.to_string
    Logger.info "MQTT Client #{client} Connecting: #{@host}:#{@port}"
    priv_dir = :code.priv_dir(:brood)
    transport = {:ssl, [{:certfile, "#{priv_dir}/ssl/cicada.crt"}, {:keyfile, "#{priv_dir}/ssl/cicada.key"}]}
    GenMQTT.start_link(__MODULE__, nil, host: @host, port: @port, name: __MODULE__, client: client, transport: transport)
  end

  def on_connect(state) do
    Logger.info "MQTT Connected"
    :ok = GenMQTT.subscribe(self, "node/+/+", 0)
    {:ok, state}
  end

  def on_publish(["node", client, "payload"], message, state) do
    Logger.info "#{client} Published: #{inspect message}"
    Task.Supervisor.start_child(Brood.TaskSupervisor, fn -> {client, message} |> process end)
    {:ok, state}
  end

  def process({client, data}) do
    data
    |> parse(client)
    |> meta
    |> write
    |> publish
  end

  def parse(data, client) do
    timestamp = :os.system_time(:nano_seconds)
    data |> Poison.decode! |> Enum.flat_map(fn device ->
      device |> Map.get("values") |> Enum.map(fn v ->
        key = v |> Map.get("key") |> Enum.join(".")
        type = device |> get_in(["device", "type"])
        %{
          measurement: "#{type}.#{key}",
          timestamp: timestamp,
          fields: %{
            value: case v |> Map.get("value") do
              num when num |> is_number -> num / 1
              text -> text
            end
          },
          tags: %{
            node_id: client,
            id: device |> get_in(["device", "interface_pid"]),
            type: type,
            zipcode: nil,
            climate_zone: nil
          }
        }
      end)
    end)
  end

  def meta(points) do
    #TODO lookup zipcode/climate zone
    zip = "60626"
    cz = "6a"
    points |> Enum.map(fn p ->
      %{p | tags: %{p.tags | zipcode: zip, climate_zone: cz}} #dummy data
    end)
  end

  def write(points) do
    Logger.info "#{inspect points}"
    points |> Brood.DB.InfluxDB.write_points
  end

  def publish(points) do
    points |> Enum.each(fn p -> SatoriPublisher.publish(p) end)
    points
  end

end
