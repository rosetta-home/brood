use Mix.Config

config :brood,
  mongo_host: "localhost",
  mqtt_host: "localhost",
  acme_server: "https://acme-staging.api.letsencrypt.org"

config :brood, Brood.DB.InfluxDB,
  host: "localhost"
