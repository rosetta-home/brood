defmodule Cicada.Supervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      Cicada.DB.InfluxDB.child_spec,
      supervisor(Task.Supervisor, [[name: Cicada.TaskSupervisor]]),
      worker(Cicada.Server, []),
    ]
    supervise(children, strategy: :one_for_one)
  end

end
