defmodule BroodAccountTest do
  use ExUnit.Case
  use Plug.Test
  require Logger
  alias Brood.Resource.Account
  doctest Brood

  @location_name "CRT Labs"
  @email "test@test.com"
  @password "123456é$@_''"
  @kit_id "596500cf024b160a70a4ea72"
  @zipcode "60626"
  @params %{"location_name" => @location_name, "email" => @email, "password" => @password, "password_conf" => @password, "kit_id" => @kit_id, "zipcode" => @zipcode}

  setup do
    on_exit fn ->
      Logger.debug "Clearing test account"
      @params
      |> Account.parse_params()
      |> Account.find_user()
      |> Account.delete()
    end
    :ok
  end

  test "registration" do
    conn = conn(:put, "/account/register", @params) |> put_req_header("content-type", "multipart/form-data")
    result = Brood.HTTPRouter.call(conn, [])
    assert result.status == 200
  end

  test "email_taken" do
    conn = conn(:put, "/account/register", @params) |> put_req_header("content-type", "multipart/form-data")
    Brood.HTTPRouter.call(conn, [])
    try do
      conn = conn(:put, "/account/register", @params) |> put_req_header("content-type", "multipart/form-data")
      Brood.HTTPRouter.call(conn, [])
    rescue
      _clause in CaseClauseError -> assert true
    end
  end

  test "login" do
    conn = conn(:put, "/account/register", @params) |> put_req_header("content-type", "multipart/form-data")
    _result = Brood.HTTPRouter.call(conn, [])
    conn2 = conn(:post, "/account/login", %{"email": @email, "password": @password}) |> put_req_header("content-type", "multipart/form-data")
    result2 = Brood.HTTPRouter.call(conn2, [])
    assert result2.private.plug_rest_body |> Poison.decode! |> Map.has_key?("account")
    assert result2.status == 200
  end
end
