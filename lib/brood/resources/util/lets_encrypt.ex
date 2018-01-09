defmodule Brood.Resource.Util.LetsEncrypt do
  require Logger

  def init(_, req, []) do
    {host, _} = :cowboy_req.host(req)
    Logger.info "Let's Encypt Host: #{host}"
    challenges = :letsencrypt.get_challenge()
    {token, _}  = :cowboy_req.binding(:token, req)
    Logger.info "Got token: #{inspect token}"
    {:ok, req2} =
      case challenges |> Map.get(host) do
        %{token: token, thumbprint: thumbprint} ->
          Logger.info "Got thumbprint: #{inspect thumbprint}"
          :cowboy_req.reply(200, [{"content-type", "text/plain"}], thumbprint, req)
        _ ->
          :cowboy_req.reply(404, req)
      end
    {:ok, req2, %{}}
  end

  def handle(req, state) do
    {:ok, req, state}
  end

  def terminate(_reason, _req, _state), do: :ok

end
