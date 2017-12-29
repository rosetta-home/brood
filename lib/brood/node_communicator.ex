defmodule Brood.NodeCommunicator do
  use GenMQTT
  require Logger

  @host Application.get_env(:brood, :mqtt_host)
  @port Application.get_env(:brood, :mqtt_port)

  defmodule State do
    defstruct [:id]
  end

  def start_link(node_id, state \\ %State{}) do
    state = %State{id: node_id}
    client = "Server:#{node_id}"
    Logger.info "MQTT Client #{client} Connecting: #{@host}:#{@port}"
    priv_dir = :code.priv_dir(:brood)
    transport = {:ssl, [{:certfile, "#{priv_dir}/ssl/cicada.crt"}, {:keyfile, "#{priv_dir}/ssl/cicada.key"}]}
    GenMQTT.start_link(__MODULE__, state , host: @host, port: @port, client: client, transport: transport)
  end

  def request(id, payload), do: GenMQTT.call(id, {:request, payload})

  def on_connect(state) do
    Logger.info "MQTT Connected"
    :ok = GenMQTT.subscribe(self, "node/Node:#{state.id}/response", 0)
    {:ok, state}
  end

  def on_publish(["node", client, "response"], message, state) do
    Logger.info "#{client} Response Received: #{inspect message}"
    #Task.Supervisor.start_child(Brood.TaskSupervisor, fn -> {client, message} |> process end)
    {:ok, state}
  end

  def on_publish(["node", client, "request"], message, state) do
    Logger.info "#{client} Request Sent: #{inspect message}"
    #Task.Supervisor.start_child(Brood.TaskSupervisor, fn -> {client, message} |> process end)
    {:ok, state}
  end

  def on_publish(_, _, state) do
    {:ok, state}
  end

  def handle_call({:request, payload}, _from, state) do
    topic = "node/Node:#{state.id}/request"
    Logger.info "Node Request:#{topic} => #{inspect payload}"
    self() |> GenMQTT.publish(topic, payload |> Poison.encode!, 1)
    {:reply, :ok, state}
  end

  def process({client, data}) do
    data
    |> parse(client)
    |> meta
    |> write
    |> publish
  end

  def parse(data, client) do
    Logger.info "Data from: #{client} => #{inspect data}"
    []
  end

  def meta(points) do
    points
  end

  def write(points) do
    points
  end

  def publish(points) do
    points
  end

end
