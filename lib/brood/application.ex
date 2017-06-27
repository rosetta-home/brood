defmodule Brood.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    children = [
      #Brood.DB.InfluxDB.child_spec,
      Plug.Adapters.Cowboy.child_spec(:http, Brood.HTTPRouter, [], [port: 8080]),
      #supervisor(Task.Supervisor, [[name: Brood.TaskSupervisor]]),
      #worker(Brood.SatoriPublisher, []),
      #worker(Brood.MQTTHandler, []),
    ]
    opts = [strategy: :one_for_one, name: Brood.Supervisor]
    Supervisor.start_link(children, opts) |> create_db
  end

  def create_db({:ok, pid} = result) do
    #Brood.DB.InfluxDB.wait_till_up
    #Brood.DB.InfluxDB.create_database
    #Brood.DB.InfluxDB.create_retention_policies
    #Brood.DB.InfluxDB.create_continuous_queries
    result
  end
end
