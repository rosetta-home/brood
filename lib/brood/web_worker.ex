defmodule Brood.WebWorker do
  require Logger
  def start_link do
    ssl_path = Application.get_env(:brood, :ssl_path)
    http_port = Application.get_env(:brood, :http_port) |> String.to_integer()
    https_port = Application.get_env(:brood, :https_port) |> String.to_integer()
    case File.exists?("#{ssl_path}/domain_cert.pem") do
      true ->
        start_redirector(http_port)
        start_https(https_port)
      false -> start_http(http_port)
    end
  end

  def start_https(port) do
    Logger.info "starting HTTPS: #{port}"
    ssl_path = Application.get_env(:brood, :ssl_path)
    Plug.Adapters.Cowboy.https(Brood.HTTPRouter, [],
      port: port,
      dispatch: dispatch(),
      keyfile: "#{ssl_path}/domain.pem",
      certfile: "#{ssl_path}/domain_cert.pem",
      versions: [:"tlsv1.2", :"tlsv1.1", :"tlsv1"],
      ciphers: ~w(
        ECDHE-ECDSA-AES256-GCM-SHA384
        ECDHE-ECDSA-AES256-SHA384
        ECDHE-ECDSA-AES128-GCM-SHA256
        ECDHE-ECDSA-AES128-SHA256
        ECDHE-ECDSA-AES256-SHA
        ECDHE-ECDSA-AES128-SHA

        ECDHE-RSA-AES256-GCM-SHA384
        ECDHE-RSA-AES256-SHA384
        ECDHE-RSA-AES128-GCM-SHA256
        ECDHE-RSA-AES128-SHA256
        ECDHE-RSA-AES256-SHA
        ECDHE-RSA-AES128-SHA

        ECDH-ECDSA-AES256-GCM-SHA384
        ECDH-ECDSA-AES256-SHA384
        ECDH-ECDSA-AES128-GCM-SHA256
        ECDH-ECDSA-AES128-SHA256

        DHE-RSA-AES256-GCM-SHA384
        DHE-RSA-AES256-SHA256
        DHE-DSS-AES256-GCM-SHA384
        DHE-DSS-AES256-SHA256
        DHE-RSA-AES256-SHA
        DHE-DSS-AES256-SHA

        DHE-DSS-AES128-GCM-SHA256
        DHE-RSA-AES128-GCM-SHA256
        DHE-RSA-AES128-SHA256
        DHE-DSS-AES128-SHA256
        DHE-RSA-AES128-SHA
        DHE-DSS-AES128-SHA

        AES128-GCM-SHA256
        AES128-SHA
        DES-CBC3-SHA
      )c,
      secure_renegotiate: true,
      reuse_sessions: true,
      honor_cipher_order: true,
      client_renegotiation: false,
      eccs: [
        :sect571r1, :sect571k1, :secp521r1, :brainpoolP512r1, :sect409k1,
        :sect409r1, :brainpoolP384r1, :secp384r1, :sect283k1, :sect283r1,
        :brainpoolP256r1, :secp256k1, :secp256r1, :sect239k1, :sect233k1,
        :sect233r1, :secp224k1, :secp224r1
      ],
    )
  end

  def start_http(port) do
    Logger.info "starting HTTP: #{port}"
    Plug.Adapters.Cowboy.http(Brood.HTTPRouter, [],
      port: port,
      dispatch: dispatch(),
    )
  end

  def start_redirector(port) do
    Logger.info "starting HTTP: #{port}"
    Plug.Adapters.Cowboy.http(Brood.HTTPSRedirector, [],
      port: port,
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
