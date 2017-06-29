defmodule Brood.Resource.Account.SecretKey do

  def fetch do
    dir = :code.priv_dir(:brood)
    JOSE.JWK.from_file("#{dir}/jwt_key.bin")
  end

end
