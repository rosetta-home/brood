defmodule Brood.Resource.Account.GuardianSerializer do
  @behaviour Guardian.Serializer

  alias Brood.Resource.Account

  def for_token(account = %Account{}) do
    id = BSON.ObjectId.encode!(account._id)
    {:ok, "Account:#{id}" }
  end
  def for_token(_), do: { :error, "Unknown resource type" }

  def from_token("Account:" <> id) do
    account = Account.from_id(id)
    { :ok, account }
  end
  def from_token(_), do: { :error, "Unknown resource type" }
end
