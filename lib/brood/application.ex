defmodule Brood.Application do
  use Application
  alias Brood.Resource.Account
  require Logger

  @mongo_database Application.get_env(:brood, :mongo_database)
  @mongo_host Application.get_env(:brood, :mongo_host)
  @http_port Application.get_env(:brood, :http_port)
  #@account_collection Application.get_env(:brood, :account_collection)

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    children = [
      Brood.DB.InfluxDB.child_spec,
      Plug.Adapters.Cowboy.child_spec(:http, Brood.HTTPRouter, [], [port: @http_port, dispatch: dispatch()]),
      supervisor(Task.Supervisor, [[name: Brood.TaskSupervisor]]),
      worker(Mongo, [[name: :mongo_brood, hostname: @mongo_host, database: @mongo_database, pool: DBConnection.Poolboy]]),
      worker(Brood.SatoriPublisher, []),
      worker(Brood.MQTTHandler, []),
    ]
    opts = [strategy: :one_for_one, name: Brood.Supervisor]
    Supervisor.start_link(children, opts) |> create_influx_db |> create_mongo_db
  end

  def create_influx_db({:ok, _pid} = result) do
    Brood.DB.InfluxDB.wait_till_up
    Brood.DB.InfluxDB.create_database
    Brood.DB.InfluxDB.create_retention_policies
    Brood.DB.InfluxDB.create_continuous_queries
    result
  end

  def create_mongo_db({:ok, _pid} = result) do
    Account.index()
    result
  end

  defp dispatch do
    [
      {:_, [
        {"/ws", Brood.Resource.WebSocket.Handler, []},
        {"/static/[...]", :cowboy_static, {:priv_dir,  :brood, "static"}},
        {:_, Plug.Adapters.Cowboy.Handler, {Brood.HTTPRouter, []}}
      ]}
    ]
  end
end
