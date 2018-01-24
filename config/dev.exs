use Mix.Config

config :brood,
  mongo_host: "localhost",
  mqtt_host: "localhost",
  acme_server: "https://acme-staging.api.letsencrypt.org",
  ssl_path: "/app/rosetta-home/brood/priv/ssl"

config :brood, Brood.DB.InfluxDB,
  host: "localhost"
