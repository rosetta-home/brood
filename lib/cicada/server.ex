defmodule Cicada.Server do
  require Logger

  def start_link do
    port = Application.get_env(:cicada, :port)
    Logger.info "Starting Server on port #{port}"
    priv_dir = :code.priv_dir(:cicada)
    dispatch = :cowboy_router.compile([
      { :_,
        [
          {"/", Cicada.Index, []},
          {"/test", Cicada.Test, []}
        ]
      }
    ])
    {:ok, _} = :cowboy.start_https(:https, 100,
      [
        {:ip, {0,0,0,0}},
        {:port, port},
        {:cacertfile, "#{priv_dir}/certs/certs/ca.crt"},
	      {:certfile, "#{priv_dir}/certs/certs/RosettaHomeServer.crt"},
	      {:keyfile, "#{priv_dir}/certs/RosettaHomeServer.key"},
        {:verify, :verify_peer},
        {:fail_if_no_peer_cert, true},
      ],
      [{:env, [{:dispatch, dispatch}]}]
    )
  end

end
