defmodule Brood.Server do
  require Logger

  def start_link do
    port = Application.get_env(:brood, :port, 4000)
    Logger.info "Starting Server on port #{port}"
    priv_dir = :code.priv_dir(:brood)
    Logger.info "Priv Dir #{priv_dir}"
    dispatch = :cowboy_router.compile([
      { :_,
        [
          {"/", Brood.Index, []},
          {"/test", Brood.Test, []}
        ]
      }
    ])
    Logger.info "#{inspect dispatch}"
    {:ok, ok} = :cowboy.start_https(:https, 100,
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
    Logger.info "#{inspect ok}"
    {:ok, ok}
  end

end
