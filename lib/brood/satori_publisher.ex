defmodule Brood.SatoriPublisher do
  use GenServer
  require Logger
  alias Satori.PDU

  @publish_channel "rosetta-home"

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def publish(data) do
    GenServer.cast(__MODULE__, {:publish, data})
  end

  def init(:ok) do
    url = "#{Application.get_env(:satori, :url)}?appkey=#{Application.get_env(:satori, :app_key)}"
    Logger.info "URL: #{url}"
    {:ok, pub} = Satori.Publisher.start_link(url, @publish_channel, Application.get_env(:satori, :role_secret))
    {:ok, %{pub: pub}}
  end

  def handle_cast({:publish, data}, state) do
    Satori.Publisher.publish(state.pub, data)
    {:noreply, state}
  end

end
