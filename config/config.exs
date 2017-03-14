# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :brood,
  influx_database: "brood",
  port: 4000,
  mqtt_host: "localhost",
  mqtt_port: 4883

config :brood, Brood.DB.InfluxDB,
    host:      "influxdb",
    pool:      [ max_overflow: 10, size: 5 ],
    port:      8086,
    scheme:    "http",
    writer:    Instream.Writer.Line

import_config "keys.exs"
