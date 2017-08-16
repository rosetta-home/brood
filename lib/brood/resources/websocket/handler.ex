defmodule Brood.Resource.WebSocket.Handler do
  require Logger
  @behaviour :cowboy_websocket_handler

  defmodule Message do
    @derive [Poison.Encoder]
    defstruct [:type, :payload]
  end

  defmodule Error do
    @derive [Poison.Encoder]
    defstruct [:message]
  end

  defmodule State do
    defstruct [:current_id]
  end

  def init(_, _req, _opts) do
    {:upgrade, :protocol, :cowboy_websocket}
  end

  @timeout 60000 # terminate if no activity for one minute

  #Called on websocket connection initialization.
  def websocket_init(_type, req, _opts) do
    {auth, req2} = :cowboy_req.header("Authorization", req)
    Logger.debug("#{inspect auth}")
    #case auth do
    #  :undefined ->
    #    Logger.debug "No Authentication token present"
    #    {:shutdown, req2}
    #  _ ->
    #    #TODO check auth token
    #    #case Guardian.decode_and_verify(auth) do
    #    #  { :ok, claims } -> do_things_with_claims(claims)
    #    #  { :error, reason } -> do_things_with_an_error(reason)
    #    #end
    #    {:ok, req2, %State{}, @timeout}
    #end
    {:ok, req2, %State{}, @timeout}
  end

  # Handle other messages from the browser - don't reply
  def websocket_handle({:text, message}, req, state) do
    {reply, state} =
      case Poison.decode(message, as: %Message{}) do
        {:ok, mes} -> mes |> handle_message(state)
        {:error, er} -> {%Error{message: er}, state}
      end
    Logger.debug("#{inspect reply}")
    {:reply, {:text, reply |> Poison.encode!}, req, state}
  end

  def handle_message(%Message{type: "ping"} = mes, state) do
    {%Message{type: "pong", payload: %{ok: :yes}}, state}
  end

  def handle_message(%Message{type: "configure"} = mes, state) do
    :timer.sleep(10000)
    {%Message{type: "configuration_state", payload: %{current_id: 1}}, state}
  end

  def handle_message(%Message{} = mes, state) do
    {%Message{type: "unknown_type", payload: %{type: mes.type}}, state}
  end

  # Format and forward elixir messages to client
  def websocket_info(message, req, state) do
    {:reply, {:text, message}, req, state}
  end

  # No matter why we terminate, remove all of this pids subscriptions
  def websocket_terminate(_reason, _req, _state) do
    :ok
  end
end
