# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :cicada,
  influx_database: "cicada",
  port: 4000

config :cicada, Cicada.DB.InfluxDB,
    host:      "influxdb",
    pool:      [ max_overflow: 10, size: 5 ],
    port:      8086,
    scheme:    "http",
    writer:    Instream.Writer.Line

import_config "keys.exs"
