FROM elixir:1.4.2

RUN mkdir /app
WORKDIR /app

# Install Elixir Deps
ADD mix.* ./
RUN MIX_ENV=prod mix local.rebar
RUN MIX_ENV=prod mix local.hex --force
RUN MIX_ENV=prod mix deps.get

# Install app
ADD . .
RUN MIX_ENV=prod mix compile

# The command to run when this image starts up
CMD MIX_ENV=prod mix run --no-halt
