defmodule Mix.Tasks.GenerateSslCerts do
  use Mix.Task
  require Logger

  @shortdoc "Generate SSL Certs from Let's Encrypt"
  @moduledoc """
  Get SSL Certs
  """
  def run(_args) do
    Application.ensure_all_started(:acme)
    ssl_path = Application.get_env(:brood, :ssl_path)
    subject = Application.get_env(:brood, :cert_subject)
    domain_name = Application.get_env(:brood, :domain_name)
    acme_registration = Application.get_env(:brood, :acme_registration)
    user = "#{ssl_path}/user.pem"
    domain = "#{ssl_path}/domain.pem"
    case File.exists?(user) && File.exists?(domain) do
      false ->
        user |> generate_private_pem()
        domain |> generate_private_pem()
      true -> nil
    end
    {:ok, conn} = Acme.Client.start_link([
      server: Application.get_env(:brood, :acme_server),
      private_key_file: user
    ])
    Logger.info("#{inspect conn}")
    case Acme.register(acme_registration) |> Acme.request(conn) do
      {:ok, reg} ->
        Logger.info("#{inspect reg}")
        {:ok, agreed} = Acme.agree_terms(reg) |> Acme.request(conn)
        Logger.info("#{inspect agreed}")
      _error -> :ok
    end
    Logger.info "authorize: #{domain_name}"
    {:ok, auth} = Acme.authorize(domain_name) |> Acme.request(conn)
    Logger.info("#{inspect auth}")
    challenge = auth |> Acme.Authorization.fetch_challenge("http-01")
    {:ok, bin} = Poison.encode(challenge)
    File.write!("#{ssl_path}/challenge.json", bin)
    {:ok, challenge} = Acme.respond_challenge(challenge) |> Acme.request(conn)
    Logger.info("#{inspect challenge}")
    wait_for_valid_cert(challenge)
    {:ok, csr} = Acme.OpenSSL.generate_csr(domain, subject)
    Logger.info("#{inspect csr}")
    {:ok, url} = Acme.new_certificate(csr) |> Acme.request(conn)
    Logger.info("#{inspect url}")
    {:ok, cert} = Acme.get_certificate(url) |> Acme.request(conn)
    Logger.info("#{inspect cert}")
    File.write!("#{ssl_path}/domain_cert.der", cert)
    Mix.shell.cmd("openssl x509 -in #{ssl_path}/domain_cert.der -inform DER -out #{ssl_path}/domain_cert.pem")
    File.rm("#{ssl_path}/domain_cert.der")
    Mix.shell.info("SSL Certificates generated, please restart Brood")
  end

  def generate_private_pem(file) do
    Mix.shell.cmd("openssl genrsa -out #{file} 4096")
    file
  end

  def wait_for_valid_cert(challenge) do
    Logger.info "Checking status: #{inspect challenge}"
    case HTTPoison.get(challenge.uri) do
      {:ok, %HTTPoison.Response{status_code: 202, body: body}} ->
        case Poison.decode!(body) do
          %{"status" => "valid"} -> :ok
          _ ->
            :timer.sleep(1000)
            wait_for_valid_cert(challenge)
        end
      _ ->
        :timer.sleep(1000)
        wait_for_valid_cert(challenge)
    end
  end

end
