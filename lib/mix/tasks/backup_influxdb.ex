defmodule Mix.Tasks.BackupInfluxdb do
  use Mix.Task
  require Logger

  @aws_bucket Application.get_env(:brood, :influxdb_backup_bucket)
  @influxdb_host Application.get_env(:brood, Brood.DB.InfluxDB)

  @shortdoc "Upload influxdb backup to versioned S3 bucket"
  @moduledoc """
  upload Influxdb Backup to S3
  """
  def run(_args) do
    Application.ensure_all_started(:hackney)
    Application.ensure_all_started(:poison)
    Mix.shell.cmd("influxd backup -host #{get_in(@influxdb_host, [:host])}:8088 -database brood /tmp/influxdb-backup")
    Mix.shell.cmd("cd /tmp/influxdb-backup && tar zczf /tmp/influxdb-backup.tar.gz * && rm -rf /tmp/influxdb-backup")
    Mix.shell.info "Uploading /tmp/influxdb-backup.tar.gz"
    case ExAws.S3.put_object(
      @aws_bucket,
      "influxdb-backup.tar.gz",
      File.read!("/tmp/influxdb-backup.tar.gz")
    ) |> ExAws.request!(region: "us-east-1")
    do
        %{status_code: 200} = resp ->
          Mix.shell.cmd("rm -rf /tmp/influxdb-backup.tar.gz")
          Mix.shell.info "Upload complete"
        error -> Mix.shell.error("#{inspect error}")
    end
  end
end
