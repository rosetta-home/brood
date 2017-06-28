defmodule Brood.Resource.Account do
  require Logger
  alias Brood.Resource.Account
  alias Comeonin.Pbkdf2

  @account_collection Application.get_env(:brood, :account_collection)

  defstruct _id: nil, location_name: nil, username: nil, password: nil, kit_id: nil, zipcode: nil, climate_zone: nil

  def register(%Account{} = account, password_conf) do
    case account.password == password_conf do
      true ->
        account = %Account{account | password: account.password |> Pbkdf2.hashpwsalt}
        :mongo_brood |> Mongo.insert_one(@account_collection, account, pool: DBConnection.Poolboy)
      _ -> :password_mismatch
    end
  end

  def authenticate(%Account{username: username, password: password} = auth) do
    with %Account{username: username} = account <- auth |> find_user(),
      true <- auth |> validate_pw(account)
    do
      account
    else
      false -> :invalid_password
    end
  end

  def find_user(%Account{username: username} = user) do
    with doc <- :mongo_brood |> Mongo.find_one(@account_collection, %{username: username}, pool: DBConnection.Poolboy),
      %Account{username: username} = account <- parse_params(doc),
    do: account
  end

  def validate_pw(%Account{password: password} = auth, %Account{password: hash} = account) do
    Pbkdf2.checkpw(password, hash)
  end

  def parse_params(nil), do: :no_account
  def parse_params(params) do
    %Account{}
    |> Map.to_list()
    |> Enum.reduce %Account{},
      fn({k, _}, acc) ->
        case Map.fetch(params, Atom.to_string(k)) do
          {:ok, v} -> %{acc | k => v}
          :error -> acc
        end
      end
  end

  def index() do
    indexes = [
      %{
        key: %{username: 1},
        name: "username",
        unique: true
      },
      %{
        key: %{location_name: "hashed"},
        name: "location",
        unique: false
      },
      %{
        key: %{kit_id: "hashed"},
        name: "kit",
        unique: false
      },
      %{
        key: %{zipcode: "hashed"},
        name: "zipcode",
        unique: false
      },
      %{
        key: %{climate_zone: "hashed"},
        name: "climate_zone",
        unique: false
      }
    ]
    Logger.debug "Creating #{@account_collection} Indexes: #{inspect indexes}"
    :mongo_brood |> Mongo.command!([createIndexes: @account_collection, indexes: indexes], pool: DBConnection.Poolboy)
  end
end
