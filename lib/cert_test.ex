defmodule CertTest do
  use Application

  def start(_type, _opts) do
    CertTest.Supervisor.start_link
  end
end
