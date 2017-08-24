defmodule Brood.Resource.Account.Router do
  use PlugRest.Router
  use Plug.ErrorHandler
  alias Brood.Resource.Account
  require Logger

  plug CORSPlug, origin: ["http://localhost:8080"]
  plug Plug.Parsers, parsers: [:multipart]
  plug :match
  plug :dispatch

  resource "/register", Account.Register
  resource "/login", Account.Login

  def sign(conn, account) do
    conn = Guardian.Plug.api_sign_in(conn, account)
    jwt = Guardian.Plug.current_token(conn)
    {:ok, claims} = Guardian.Plug.claims(conn)
    exp = Map.get(claims, "exp") |> Integer.to_string
    {conn
      |> Plug.Conn.put_resp_header("authorization", "Bearer #{jwt}")
      |> Plug.Conn.put_resp_header("x-expires", exp),
    jwt}
  end

  def response_body({conn, jwt}, account) do
    #TODO get hardware info from DB
    account = %Account{account |
      _id: account._id |> BSON.ObjectId.encode!,
      hardware: %Account.Hardware{
        id: "0000000081474d35",
        weather: [%{id: "345345345"}],
        energy: [%{id: "3098s0d98fs"}],
        hvac: [%{id: "sa0sd9fs9df7s"}],
        ieq: [%{id: "1"}, %{id: "2"}, %{id: "3"}, %{id: "4"}, %{id: "5"}]
      }
    }
    {conn, %{success: jwt, account: account} |> Poison.encode!}
  end

  def respond({conn, data}, state) do
    {true, conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> PlugRest.Resource.put_rest_body(data),
    state}
  end

  def handle_errors(conn,  %{reason: %CaseClauseError{term: :no_account}}) do
    send_error(conn, 422, "{\"error\": \"Invalid login\"}")
  end

  def handle_errors(conn,  %{reason: %CaseClauseError{term: :invalid_password}}) do
    send_error(conn, 422, "{\"error\": \"Invalid login\"}")
  end

  def handle_errors(conn,  %{reason: %CaseClauseError{term: :email_taken}}) do
    send_error(conn, 409, "{\"error\": \"Email address already in use\"}")
  end

  def handle_errors(conn,  %{reason: %ArgumentError{}}) do
    send_error(conn, 400, "{\"error\": \"ArgumentError\"}")
  end

  def handle_errors(conn, other) do
    Logger.error("#{inspect other}")
    send_error(conn, 500, "{\"error\": \"Ruh Roh!\"}")
  end

  def send_error(conn, status, data) do
    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> send_resp(status, data)
  end

end
