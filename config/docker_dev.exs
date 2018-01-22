use Mix.Config

config :brood,
  mongo_host: "mongodb",
  mqtt_host: "vernemq",
  acme_server: "https://acme-staging.api.letsencrypt.org"

config :brood, Brood.DB.InfluxDB,
  host: "influxdb"
