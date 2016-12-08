defmodule Cicada do
  use Application

  def start(_type, _opts) do
    {:ok, pid} = Cicada.Supervisor.start_link
    create_db
    {:ok, pid}
  end

  def create_db do
    Cicada.DB.InfluxDB.wait_till_up
    Cicada.DB.InfluxDB.create_database
    Cicada.DB.InfluxDB.create_retention_policies
    Cicada.DB.InfluxDB.create_continuous_queries
  end
end
