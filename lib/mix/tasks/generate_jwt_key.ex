defmodule Mix.Tasks.GenerateJwtKey do
  use Mix.Task
  require Logger

  @shortdoc "Generate Key for API JWT encryption"
  @moduledoc """
  Generate JWT Key for Guardian API
  """
  def run(_args) do
    dir = :code.priv_dir(:brood)
    file = "#{dir}/jwt_key.bin"
    case File.exists?(file) do
      true -> Mix.shell.info "Key file already exists"
      false -> generate_key_file(file)
    end
  end

  def generate_key_file(file) do
    Mix.shell.info "Creating Key: #{file}"
    JOSE.JWS.generate_key(%{"alg" => "HS512"})
    |> JOSE.JWK.to_binary
    |> elem(1)
    |> write_file(file)
    Mix.shell.info "Key created in #{file}"
  end

  def write_file(bin, file) do
    File.write(file, bin, [:write])
  end
end
