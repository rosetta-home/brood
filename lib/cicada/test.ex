defmodule Cicada.Test do
  require Logger

  defmodule State do
    defstruct hostname: nil
  end

  def init({:ssl, :http}, req, opts) do
    {:ok, req, %State{}}
  end

  def handle(req, state) do
    headers = [
        {"cache-control", "no-cache"},
        {"connection", "close"},
        {"content-type", "text/plain"},
        {"expires", "Mon, 3 Jan 2000 12:34:56 GMT"},
        {"pragma", "no-cache"}
    ]
    {:ok, req2} = :cowboy_req.reply(200, headers, "ok", req)
    {:ok, req2, state}
  end

  def terminate(_reason, req, state), do: :ok

end
