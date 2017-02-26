defmodule Brood.Client do
  use GenServer
  require Logger

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    Process.send_after(self, :test, 2000)
    {:ok, %{}}
  end

  def handle_info(:test, state) do
    priv_dir = :code.priv_dir(:brood)
    {reply, http} = HTTPoison.get "https://localhost:4000/", [], [
      hackney: [
        ssl_options: [
          certfile: "#{priv_dir}/certs/certs/RosettaHomeClient.crt",
          keyfile: "#{priv_dir}/certs/RosettaHomeClient.key"
        ]
      ]
    ]
    Logger.info "Reply: #{inspect http}"
    Process.send_after(self, :test, 2000)
    {:noreply, state}
  end

end
