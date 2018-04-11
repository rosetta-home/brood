FROM elixir:1.5.1
ENV DEBIAN_FRONTEND=noninteractive

MAINTAINER Christopher Coté

RUN apt-get update && apt-get install -y \
      inotify-tools \
      && rm -rf /var/lib/apt/lists/*

RUN wget https://dl.influxdata.com/influxdb/releases/influxdb_1.5.1_amd64.deb
RUN dpkg -i influxdb_1.5.1_amd64.deb

ENV HOME /opt/app
WORKDIR $HOME

RUN mix local.hex --force
RUN mix local.rebar --force

COPY mix.* ./

RUN mix deps.get --only prod

RUN mix deps.compile

COPY . .

RUN mix compile

RUN mix generate_jwt_key

CMD mix run --no-halt
