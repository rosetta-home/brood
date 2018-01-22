defmodule Brood.Resource.Util.LetsEncrypt do
  require Logger

  def init(_, req, []) do
    {host, _} = :cowboy_req.host(req)
    Logger.info "Let's Encrypt Host: #{host}"
    ssl_path = Application.get_env(:brood, :ssl_path)
    json = File.read!("#{ssl_path}/challenge.json")
    {:ok, challenge} = Poison.decode(json, as: %Acme.Challenge{})
    Logger.info("Got Challenge: #{inspect challenge}")
    {token, _}  = :cowboy_req.binding(:token, req)
    Logger.info "Got token: #{inspect token}"
    {:ok, req2} =
      case challenge.token do
        token ->
          user = "#{ssl_path}/user.pem"
          jwk = JOSE.JWK.from_pem_file(user)
          thumbprint = Acme.Challenge.create_key_authorization(token, jwk)
          Logger.info "Generated Thumbprint: #{thumbprint}"
          :cowboy_req.reply(200, [{"content-type", "text/plain"}], thumbprint, req)
        _ ->
          :cowboy_req.reply(404, [{"content-type", "text/plain"}], "", req)
      end
    {:ok, req2, %{}}
  end

  def handle(req, state) do
    {:ok, req, state}
  end

  def terminate(_reason, _req, _state), do: :ok

end
