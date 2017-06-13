defmodule Brood.SatoriPublisher do
  use GenServer
  require Logger
  alias Satori.PDU

  @publish_channel "rosetta-home"

  defmodule State do
    defstruct pub: nil
  end

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def publish(data) do
    GenServer.cast(__MODULE__, {:publish, data})
  end

  def init(:ok) do
    Process.send_after(self(), :connect, 0)
    {:ok, %State{}}
  end

  def handle_info(:connect, state) do
    url = "#{Application.get_env(:satori, :url)}?appkey=#{Application.get_env(:satori, :app_key)}"
    Logger.info "URL: #{url}"
    state =
      case Satori.Publisher.start_link(url, @publish_channel, Application.get_env(:satori, :role_secret)) do
        {:ok, pub} -> %State{state | pub: pub}
        _ ->
          Process.send_after(self(), :connect, 10_000)
          state
      end
    {:noreply, state}
  end

  def handle_cast({:publish, data}, %State{pub: nil} = state) do
    Logger.error("Satori Client not connected")
    {:noreply, state}
  end
  def handle_cast({:publish, data}, state) do
    Satori.Publisher.publish(state.pub, data)
    {:noreply, state}
  end

end
