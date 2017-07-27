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
    on_exit fn ->
      Logger.debug "Clearing test account"
      @params
      |> Account.parse_params()
      |> Account.find_user()
      |> Account.delete()
    end
    with %Account{} = account <- @params |> Account.parse_params,
      {:ok, %Mongo.InsertOneResult{} = result} <- account |> Account.register(@password),
      account <- Account.from_id(result.inserted_id)
    do
      {:ok, jwt, full_claims} = account |> Guardian.encode_and_sign()
      {:ok, %{jwt: jwt, claims: full_claims}}
    end
  end

  test "/mean/:measurement/:tag/:value/:from/:to/:bucket", %{jwt: jwt} do
    "/data/mean/ieq.co2/zipcode/60626/2017-07-24T12:12:12Z/now/1d" |> run(jwt)
  end

  test "/mean/:measurement/:tag/:value/:from/:to", %{jwt: jwt} do
    "/data/mean/ieq.co2/zipcode/60626/2017-07-24T12:12:12Z/now" |> run(jwt)
  end

  test "/mean/:measurement/:from/:to/:bucket", %{jwt: jwt} do
    "/data/mean/ieq.co2/2017-07-24T12:12:12Z/now/1d" |> run(jwt)
  end

  test "/mean/:measurement/:from/:to", %{jwt: jwt} do
    "/data/mean/ieq.co2/2017-07-24T12:12:12Z/now" |> run(jwt)
  end

  test "/count/:measurement/:from/:to", %{jwt: jwt} do
    "/data/count/ieq.co2/2017-07-24T12:12:12Z/now" |> run(jwt)
  end

  test "/sum/:measurement/:from/:to", %{jwt: jwt} do
    "/data/sum/ieq.co2/2017-07-24T12:12:12Z/now" |> run(jwt)
  end

  test "/min/:measurement/:from/:to", %{jwt: jwt} do
    "/data/min/ieq.co2/2017-07-24T12:12:12Z/now" |> run(jwt)
  end

  test "/max/:measurement/:from/:to", %{jwt: jwt} do
    "/data/max/ieq.co2/2017-07-24T12:12:12Z/now" |> run(jwt)
  end

  test "/median/:measurement/:from/:to", %{jwt: jwt} do
    "/data/median/ieq.co2/2017-07-24T12:12:12Z/now" |> run(jwt)
  end

  test "/first/:measurement/:from/:to", %{jwt: jwt} do
    "/data/first/ieq.co2/2017-07-24T12:12:12Z/now" |> run(jwt)
  end

  test "/last/:measurement/:from/:to", %{jwt: jwt} do
    "/data/last/ieq.co2/2017-07-24T12:12:12Z/now" |> run(jwt)
  end

  test "/percentile/:measurement/:from/:to", %{jwt: jwt} do
    "/data/percentile99/ieq.co2/2017-07-24T12:12:12Z/now" |> run(jwt)
    "/data/percentile95/ieq.co2/2017-07-24T12:12:12Z/now" |> run(jwt)
    "/data/percentile75/ieq.co2/2017-07-24T12:12:12Z/now" |> run(jwt)
    "/data/percentile50/ieq.co2/2017-07-24T12:12:12Z/now" |> run(jwt)
    "/data/percentile25/ieq.co2/2017-07-24T12:12:12Z/now" |> run(jwt)
    "/data/percentile10/ieq.co2/2017-07-24T12:12:12Z/now" |> run(jwt)
    "/data/percentile5/ieq.co2/2017-07-24T12:12:12Z/now" |> run(jwt)
  end

  defp run(url, jwt) do
    conn = conn(:get, url)
    |> put_req_header("authorization", "Bearer #{jwt}")
    result = Brood.HTTPRouter.call(conn, [])
    json = result.resp_body |> Poison.decode!
    assert json |> Map.has_key?("results")
  end

end
