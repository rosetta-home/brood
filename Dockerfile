FROM elixir:1.4.5

RUN mkdir /app
WORKDIR /app

# Install Elixir Deps
ADD mix.* ./
RUN MIX_ENV=prod mix local.rebar
RUN MIX_ENV=prod mix local.hex --force
RUN MIX_ENV=prod mix clean --all
RUN MIX_ENV=prod mix deps.get

# Install app
ADD . .
RUN MIX_ENV=prod mix compile

RUN MIX_ENV=prod mix generate_jwt_key

# The command to run when this image starts up
CMD MIX_ENV=prod mix run --no-halt
