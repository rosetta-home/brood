use Mix.Config
require Logger

Logger.info "#{Mix.env}.exs"
config :brood,
  influx_database: "brood",
  mongo_host: "mongodb",
  mongo_database: "brood",
  mqtt_host: "vernemq",
  mqtt_port: 4883,
  http_port: System.get_env("HTTP_PORT") || "8080",
  account_collection: "accounts",
  acme_server: "https://acme-v01.api.letsencrypt.org"

config :brood, Brood.DB.InfluxDB,
  host:      "influxdb",
  pool:      [ max_overflow: 10, size: 5 ],
  port:      8086,
  scheme:    "http",
  writer:    Instream.Writer.Line

config :satori,
  url: "wss://open-data.api.satori.com/v2",
  app_key: System.get_env("SATORI_APP_KEY"),
  role_secret: System.get_env("SATORI_ROLE_SECRET")

config :guardian, Guardian,
  allowed_algos: ["HS512"],
  verify_module: Guardian.JWT,
  issuer: "Brood",
  ttl: { 30, :days },
  allowed_drift: 2000,
  verify_issuer: true,
  secret_key: {Brood.Resource.Account.SecretKey, :fetch},
  serializer: Brood.Resource.Account.GuardianSerializer

import_config "#{Mix.env}.exs"
import_config "keys.exs"
