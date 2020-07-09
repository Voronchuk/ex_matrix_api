# ExMatrixApi
Elixir API to communicate with Matrix Synapse

Currently it's work in progress for internal usage, missing tests, use at your own risk.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_matrix_api` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_matrix_api, "~> 0.1.2"}
  ]
end
```

## Configuration example
```elixir
  # Configure access to Matrix Synapse
  config :ex_matrix_api, ExMatrixApi.Synapse,
    host: "matrix.local",
    registration_secret: "__some_secret_key__",
    http_client: UtilsHttp.Client.HTTPoison, # configured by default
    uuid_function: &Ecto.UUID.generate/0 # any uuid4 generator function
```
