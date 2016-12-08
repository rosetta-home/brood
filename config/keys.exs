use Mix.Config
config :cicada, keys: %{
  weather: %{
    tags: ["id"],
    values: [
      ["outdoor_temperature"],
      ["indoor_temperature"],
      ["humidity"],
      ["pressure"],
      ["wind", "speed"],
      ["wind", "direction"],
      ["wind", "gust"],
      ["rain"],
      ["uv"],
      ["solar", "radiation"],
      ["solar", "intensity"],
    ]
  },
  energy: %{
    tags: ["id"],
    values: [
      ["price"],
      ["delivered"],
      ["received"],
      ["kw"]
    ]
  },
  ieq: %{
    tags: ["id"],
    values: [
      ["battery"],
      ["co2"],
      ["energy"],
      ["pressure"],
      ["humidity"],
      ["light"],
      ["no2"],
      ["co"],
      ["pm"],
      ["rssi"],
      ["sound"],
      ["temperature"],
      ["uv"],
      ["voc"]
    ]
  },
  hvac: %{
    tags: ["id"],
    values: [
      ["state"],
      ["mode"],
      ["fan_mode"],
      ["fan_state"],
      ["target_temperature"],
      ["temperature"]
    ]
  }
}
