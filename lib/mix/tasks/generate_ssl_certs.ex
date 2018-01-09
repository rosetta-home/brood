defmodule Mix.Tasks.GenerateSslCerts do
  use Mix.Task
  require Logger

  @shortdoc "Generate SSL Certs from Let's Encrypt"
  @moduledoc """
  Get SSL Certs
  """
  def run(_args) do
    Application.ensure_all_started(:letsencrypt)
    dir = :code.priv_dir(:brood)
    :letsencrypt.start([{:mode, :slave}, :staging, {:cert_path, '#{dir}/ssl'}])
    :letsencrypt.make_cert(System.get_env("DOMAIN"), %{callback: fn(data) -> on_complete(data) end})
  end

  def on_complete({state, data}) do
    Logger.info "Let's Encrypt: #{inspect state}"
    Logger.info "Let's Encrypt: #{inspect data}"
  end
end
