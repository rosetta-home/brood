defmodule Brood.NodeCommunicator do
  use GenMQTT
  require Logger

  @host Application.get_env(:brood, :mqtt_host)
  @port Application.get_env(:brood, :mqtt_port)

  @realtime_inf "realtime_inf"

  @end_points ["request", "response", "point"]

  defmodule State do
    defstruct [:id, :parent]
  end

  def start_link(parent, node_id, state \\ %State{}) do
    state = %State{id: node_id, parent: parent}
    client = "Server:#{node_id}"
    Logger.info "MQTT Client #{client} Connecting: #{@host}:#{@port}"
    priv_dir = :code.priv_dir(:brood)
    transport = {:ssl, [{:certfile, "#{priv_dir}/ssl/cicada.crt"}, {:keyfile, "#{priv_dir}/ssl/cicada.key"}]}
    GenMQTT.start_link(__MODULE__, state , host: @host, port: @port, client: client, transport: transport)
  end

  def request(id, payload), do: GenMQTT.call(id, {:request, payload})

  def on_connect(state) do
    Logger.info "MQTT Connected"
    topics = @end_points |> Enum.map(fn ep ->
      {"node/#{state.id}/#{ep}", 1}
    end)
    :ok = GenMQTT.subscribe(self(), topics)
    {:ok, state}
  end

  def on_subscribe(_subscriptions, state) do
    {:ok, state}
  end

  def on_publish(["node", client, "response"], message, %State{id: id} = state) when client ==  id do
    Logger.info "#{client} Response Received: #{inspect message}"
    {:ok, state}
  end

  def on_publish(["node", client, "request"], message, %State{id: id} = state) when client ==  id do
    Logger.info "#{client} Request Sent: #{inspect message}"
    {:ok, state}
  end

  def on_publish(["node", client, "point"], message, %State{id: id} = state) when client ==  id do
    Logger.info "#{client} Data Point Received: #{inspect message}"
    {:ok, state}
  end

  def on_publish(_, _, state) do
    {:ok, state}
  end

  def handle_call({:request, payload}, _from, state) do
    topic = "node/#{state.id}/request"
    Logger.info "Node Request:#{topic} => #{inspect payload}"
    self() |> GenMQTT.publish(topic, payload |> Poison.encode!, 1)
    {:reply, :ok, state}
  end
end
