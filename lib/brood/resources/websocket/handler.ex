defmodule Brood.Resource.WebSocket.Handler do
  require Logger
  @behaviour :cowboy_websocket_handler
  @timeout 60000

  #Message Types
  @bearer "Bearer "
  @authentication "authentication"
  @ping "ping"
  @configure "configure"
  @configuration_state "configuration_state"
  @pong "pong"

  defmodule Message do
    @derive [Poison.Encoder]
    defstruct _type: :message,
      type: nil,
      payload: nil
  end

  defmodule Error do
    @derive [Poison.Encoder]
    defstruct _type: :error, message: nil
  end

  defmodule State do
    defstruct [authenticated: false]
  end

  def init(_, _req, _opts) do
    {:upgrade, :protocol, :cowboy_websocket}
  end

  def websocket_init(_type, req, _opts) do
    req1 = :cowboy_req.set_resp_header("access-control-allow-methods", "GET, OPTIONS", req)
    req2 = :cowboy_req.set_resp_header("access-control-allow-origin", "http://localhost:8080", req1)
    {:ok, req2, %State{}, @timeout}
  end

  def websocket_handle({:text, <<@bearer, token :: binary>>}, req, state) do
    Logger.debug("#{inspect token}")
    {reply, state} =
      case Guardian.decode_and_verify(token) do
        {:ok, claims} ->
          state = %State{state | authenticated: true}
          {%Message{type: @authentication, payload: state}, state}
        {:error, reason} -> {%Error{message: :invalid_token}, state}
      end
      {:reply, {:text, reply |> Poison.encode!}, req, state}
  end

  def websocket_handle(_m, req, %State{authenticated: false} = state) do
    Process.send_after(self(), :shutdown, 0)
    {:reply, {:text, %Error{message: :not_authenticated} |> Poison.encode!}, req, state}
  end

  def websocket_handle({:text, message}, req, %State{authenticated: true} = state) do
    {reply, state} =
      case Poison.decode(message, as: %Message{}) do
        {:ok, mes} -> mes |> handle_message(state)
        {:error, er} -> {%Error{message: er}, state}
      end
    Logger.debug("#{inspect reply}")
    {:reply, {:text, reply |> Poison.encode!}, req, state}
  end

  def handle_message(%Message{type: @ping} = mes, state) do
    {%Message{type: @pong, payload: %{ok: :yes}}, state}
  end

  def handle_message(%Message{type: @configure} = mes, state) do
    :timer.sleep(10000)
    {%Message{type: @configuration_state, payload: %{current_id: 1}}, state}
  end

  def handle_message(%Message{} = mes, state) do
    {%Message{type: :unknow_type, payload: %{type: mes.type}}, state}
  end

  def websocket_info(:shutdown, req, state) do
    {:shutdown, req, state}
  end

  def websocket_info(message, req, state) do
    {:reply, {:text, message}, req, state}
  end

  def websocket_terminate(_reason, _req, _state) do
    :ok
  end
end
