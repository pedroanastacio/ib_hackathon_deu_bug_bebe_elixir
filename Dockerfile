FROM elixir:1.14

RUN mix local.hex --force && \
    mix local.rebar --force

WORKDIR /app

COPY mix.exs mix.lock ./

RUN mix deps.get

COPY . .

RUN mix do compile

EXPOSE 3000

CMD ["mix", "run", "--no-halt"]