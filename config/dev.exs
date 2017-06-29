use Mix.Config

config :brood,
  mongo_host: "localhost",
  mqtt_host: "localhost"

config :brood, Brood.DB.InfluxDB,
  host:      "localhost"
