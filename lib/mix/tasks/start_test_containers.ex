defmodule Mix.Tasks.StartTestContainers do
  use Mix.Task
  require Logger

  @shortdoc "Start db containers for tests"
  @moduledoc """
  Start db containers for tests
  """
  def run(_args) do
    Mix.shell.cmd("docker-compose start influxdb")
    Mix.shell.cmd("docker-compose start mongodb")
    Mix.shell.cmd("docker-compose start vernemq")
  end
end
