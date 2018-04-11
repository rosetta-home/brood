defmodule Brood.DB.InfluxDB do
  use Instream.Connection, otp_app: :brood
  require Logger

  @db Application.get_env(:brood, :influx_database)

  def wait_till_up do
    case ping() do
      :pong -> :ok
      :error ->
        Logger.error "waiting for influxdb to come up..."
        :timer.sleep(300)
        wait_till_up()
    end
  end

  def create_database do
    "#{@db}"
    |> Instream.Admin.Database.create()
    |> execute()
  end

  def create_retention_policies do
    Instream.Admin.RetentionPolicy.create(
      "realtime_inf", @db, "1800d", 1
    ) |> execute()
    Instream.Admin.RetentionPolicy.alter(
      "realtime_inf", @db, "DURATION 1800d REPLICATION 1"
    ) |> execute()
    Instream.Admin.RetentionPolicy.create(
      "realtime", @db, "1800d", 1, true
    ) |> execute() #default
    Instream.Admin.RetentionPolicy.alter(
      "realtime", @db, "DURATION 1800d REPLICATION 1 DEFAULT"
    ) |> execute() #default
    Instream.Admin.RetentionPolicy.create(
      "fifteen_minute", @db, "1800d", 1
    ) |> execute()
    Instream.Admin.RetentionPolicy.alter(
      "fifteen_minute", @db, "DURATION 1800d REPLICATION 1"
    ) |> execute()
    Instream.Admin.RetentionPolicy.create(
      "one_hour", @db, "INF", 1
    ) |> execute()
  end

  def create_continuous_queries do
    """
    CREATE CONTINUOUS QUERY cq_15m ON #{@db}
    BEGIN SELECT mean(value) AS value
    INTO "#{@db}"."fifteen_minute".:MEASUREMENT FROM /.*/ GROUP BY time(15m), * END
    """ |> execute(method: :post)
    """
    CREATE CONTINUOUS QUERY cq_1h ON #{@db}
    BEGIN SELECT mean(value) as value
    INTO "#{@db}"."one_hour".:MEASUREMENT FROM /.*/ GROUP BY time(1h), * END
    """ |> execute(method: :post)
  end

  def write_points(points, retention_policy \\ "realtime") do
    case %{database: @db, points: points} |> write(retention_policy: retention_policy, database: @db) do
      :ok = resp ->
        Logger.debug "#{inspect resp}"
        points
      anything ->
        Logger.error "#{inspect anything}"
        points
    end
  end
end
