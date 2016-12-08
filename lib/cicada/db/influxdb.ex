defmodule Cicada.DB.InfluxDB do
  use Instream.Connection, otp_app: :cicada

  require Logger
  @db Application.get_env(:cicada, :influx_database)

  def wait_till_up do
    case ping do
      :pong -> :ok
      :error ->
        Logger.error "waiting for influxdb to come up..."
        :timer.sleep(300)
        wait_till_up
    end
  end

  def create_database do
    "#{@db}"
    |> Instream.Admin.Database.create()
    |> execute()
  end

  def create_retention_policies do
    Instream.Admin.RetentionPolicy.create(
      "realtime", @db, "30d", 1, true
    ) |> execute() #default

    Instream.Admin.RetentionPolicy.create(
      "fifteen_minute", @db, "360d", 1
    ) |> execute()

    Instream.Admin.RetentionPolicy.create(
      "one_hour", @db, "INF", 1
    ) |> execute()
  end

  def create_continuous_queries do
    """
    CREATE CONTINUOUS QUERY cq_15m ON #{@db}
    BEGIN SELECT mean(value) AS value
    INTO "#{@db}"."fifteen_minute".:MEASUREMENT FROM /.*/ GROUP BY id, node_id time(15m) END
    """ |> execute(method: :post)
    """
    CREATE CONTINUOUS QUERY cq_1h ON #{@db}
    BEGIN SELECT mean(value)
    INTO "#{@db}"."one_hour".:MEASUREMENT FROM /.*/ GROUP BY id, node_id, time(1h) END
    """ |> execute(method: :post)
  end

  def write_points(points) do
    case %{database: @db, points: points} |> write(database: @db) do
      {status, headers, response} ->
        Logger.debug "#{inspect status}"
        Logger.debug "#{inspect headers}"
        Logger.debug "#{inspect response}"
      anything ->
        Logger.error "#{inspect anything}"
    end
  end
end
