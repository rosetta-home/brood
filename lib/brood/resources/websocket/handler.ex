defmodule Brood.Resource.WebSocket.Handler do
  require Logger
  alias Brood.Resource.Account
  @behaviour :cowboy_websocket_handler
  @timeout 45_000

  #Message Types
  @bearer "Bearer "
  @authentication "authentication"
  @ping "ping"
  @configure_touchstone "configure_touchstone"
  @configuration_state "configuration_state"
  @touchstone_name "touchstone_name"
  @touchstone_saved "touchstone_saved"
  @pong "pong"

  defmodule Message do
    @derive [Poison.Encoder]
    defstruct _type: :message,
      id: nil,
      type: nil,
      payload: nil
  end

  defmodule Error do
    @derive [Poison.Encoder]
    defstruct _type: :error, id: nil, message: nil
  end

  defmodule State do
    defstruct [authenticated: false, node: nil, account: nil]
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
          Logger.info "Claims: #{inspect claims}"
          account =
            claims
            |> Map.get("sub")
            |> (fn "Account:" <> id -> id end).()
            |> Account.from_id
            |> Account.cleanse
            |> IO.inspect
          {:ok, node} = Brood.NodeCommunicator.start_link(self(), account.kit_id)
          state = %State{state | authenticated: true, account: account, node: node}
          {%Message{type: @authentication, payload: state}, state}
        {:error, reason} ->
          Process.send_after(self(), :shutdown, 100)
          {%Error{message: :INVALID_TOKEN}, state}
      end
      {:reply, {:text, reply |> Poison.encode!}, req, state}
  end

  def websocket_handle({:text, "ping"}, req, %State{authenticated: true} = state) do
    {:reply, {:text, "pong"}, req, state}
  end

  def websocket_handle(_m, req, %State{authenticated: false} = state) do
    Process.send_after(self(), :shutdown, 0)
    {:reply, {:text, %Error{message: :AUTH_ERROR} |> Poison.encode!}, req, state}
  end

  def websocket_handle({:text, payload}, req, %State{authenticated: true} = state) do
    Logger.debug("#{inspect payload}")
    {reply, state} = payload |> handle_payload(state)
    Logger.debug("#{inspect reply}")
    {:reply, {:text, reply |> Poison.encode!}, req, state}
  end

  def handle_payload(payload, state) do
    case Poison.decode(payload, as: %Message{}) do
      {:ok, mes} ->
        Logger.info("Got Message #{inspect mes}")
        mes |> handle_message(state)
      {:error, er} -> {%Error{message: er}, state}
    end
  end

  def handle_message(%Message{type: @ping} = mes, state) do
    {%Message{mes | type: @pong, payload: %{ok: :yes}}, state}
  end

  def handle_message(%Message{type: @configure_touchstone} = mes, state) do
    state.node |> Brood.NodeCommunicator.request(mes)
    {%Message{mes | type: @configuration_state, payload: %{current_id: 1}}, state}
  end

  def handle_message(%Message{type: @touchstone_name} = mes, state) do
    {%Message{mes | type: @touchstone_saved, payload: %{current_id: mes.payload |> Map.get("id"), name: mes.payload |> Map.get("name")}}, state}
  end

  def handle_message(%Message{} = mes, state) do
    {%Message{mes | type: :unknown_type, payload: %{type: mes.type}}, state}
  end

  def websocket_info(:shutdown, req, state) do
    {:shutdown, req, state}
  end

  def websocket_info(message, req, state) do
    dp = message |> Map.drop([:device_pid, :histogram, :timer]) |> Map.put(:_type, :message)
    {:reply, {:text, dp |> Poison.encode!}, req, state}
  end

  def websocket_terminate(_reason, req, state) do
    case state.node do
      nil -> nil
      _ -> Process.exit(state.node, :kill)
    end
    :ok
  end
end
