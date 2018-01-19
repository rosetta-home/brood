defmodule Brood.WebWorker do
  require Logger
  def start_link do
    http_port = Application.get_env(:brood, :http_port) |> String.to_integer()
    https_port = Application.get_env(:brood, :https_port) |> String.to_integer()
    case File.exists?("#{:code.priv_dir(:brood)}/ssl/domain_cert.pem") do
      true -> start_https(https_port)
      false -> start_http(http_port)
    end
  end

  def start_https(port) do
    Logger.info "starting HTTPS: #{port}"
    Plug.Adapters.Cowboy.https(Brood.HTTPRouter, [],
      port: port,
      dispatch: dispatch(),
      keyfile: "#{:code.priv_dir(:brood)}/ssl/domain.pem",
      certfile: "#{:code.priv_dir(:brood)}/ssl/domain_cert.pem"
    )
  end

  def start_http(port) do
    Logger.info "starting HTTP: #{port}"
    Plug.Adapters.Cowboy.http(Brood.HTTPRouter, [],
      port: port,
      dispatch: dispatch(),
    )
  end

  defp dispatch do
    [
      {:_, [
        {"/", Brood.Resource.UI.Index, []},
        {"/login", Brood.Resource.UI.Index, []},
        {"/register", Brood.Resource.UI.Index, []},
        {"/ws", Brood.Resource.WebSocket.Handler, []},
        {"/static/[...]", :cowboy_static, {:priv_dir,  :brood, "static"}},
        {"/build/[...]", :cowboy_static, {:priv_dir,  :brood, "ui/build"}},
        {"/.well-known/acme-challenge/:token", Brood.Resource.Util.LetsEncrypt, []},
        {:_, Plug.Adapters.Cowboy.Handler, {Brood.HTTPRouter, []}}
      ]}
    ]
  end
end
