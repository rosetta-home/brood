defmodule CertTest.Server do
  require Logger

  def start_link do
    Logger.info("test")
    port = 4000
    priv_dir = :code.priv_dir(:cert_test)

    dispatch = :cowboy_router.compile([
      { :_,
        [
          {"/", CertTest.Index, []}
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
