defmodule Brood.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    children = [
      Brood.DB.InfluxDB.child_spec,
      supervisor(Task.Supervisor, [[name: Brood.TaskSupervisor]]),
      worker(Brood.Server, []),
    ]
    opts = [strategy: :one_for_one, name: Brood.Supervisor]
    {:ok, pid} = Supervisor.start_link(children, opts)
    create_db
    {:ok, pid}
  end

  def create_db do
    Brood.DB.InfluxDB.wait_till_up
    Brood.DB.InfluxDB.create_database
    Brood.DB.InfluxDB.create_retention_policies
    Brood.DB.InfluxDB.create_continuous_queries
  end
end
