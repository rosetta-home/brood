defmodule Brood.HTTPSRedirector do
  use Plug.Router

  plug Plug.SSL
  plug :match
  plug :dispatch

  match _ do
    d = Application.get_env(:brood, :domain_name)
    send_resp(conn, 404, "try going here <a href=\"https://#{d}\" />")
  end

end
