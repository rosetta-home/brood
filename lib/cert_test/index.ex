defmodule CertTest.Index do
  require Logger

  defmodule State do
    defstruct hostname: nil
  end

  def init({:ssl, :http}, req, opts) do
    {host, req} = :cowboy_req.host(req)
    {:ok, req, %State{:hostname => host }}
  end

  def handle(req, state) do
    Logger.info(System.cwd)
    Logger.info(state.hostname)
    headers = [
        {"cache-control", "no-cache"},
        {"connection", "close"},
        {"content-type", "text/html"},
        {"expires", "Mon, 3 Jan 2000 12:34:56 GMT"},
        {"pragma", "no-cache"},
        {"Access-Control-Allow-Origin", "*"},
    ]
    {:ok, req2} = :cowboy_req.reply(200, headers, "HEY! it's encrypted", req)
    {:ok, req2, state}
  end

  def terminate(_reason, req, state), do: :ok

end
