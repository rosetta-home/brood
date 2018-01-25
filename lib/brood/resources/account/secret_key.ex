defmodule Brood.Resource.Account.SecretKey do

  def fetch do
    dir = Application.get_env(:brood, :ssl_path)
    JOSE.JWK.from_file("#{dir}/jwt_key.bin")
  end

end
