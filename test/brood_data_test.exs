defmodule BroodDataTest do
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
    {:ok, jwt, full_claims} =
      @params
      |> Account.parse_params
      |> Account.find_user
      |> Guardian.encode_and_sign()
    {:ok, %{jwt: jwt, claims: full_claims}}
  end

  test "GET /api", %{jwt: jwt} do
    conn = conn(:get, "/data/mean/ieq.co2/2017-07-24T12:12:12Z/now/1d")
    |> put_req_header("authorization", "Bearer #{jwt}")
    result = Brood.HTTPRouter.call(conn, [])
    json = result.resp_body |> Poison.decode!
    assert json |> Map.has_key?("results")
  end
end
