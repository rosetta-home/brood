use Mix.Config

config :brood,
  influx_database: "brood",
  mongo_host: "localhost",
  mongo_database: "brood",
  mqtt_host: "localhost",
  mqtt_port: 4883,
  http_port: 8080,
  account_collection: "accounts"

config :brood, Brood.DB.InfluxDB,
  host:      "localhost",
  pool:      [ max_overflow: 10, size: 5 ],
  port:      8086,
  scheme:    "http",
  writer:    Instream.Writer.Line
