use Mix.Config

config :ex_matrix_api,
  http_client: ExMatrixApi.Util.HttpClient.HTTPoison

if File.exists?("config/config.secret.exs") do
  import_config "config.secret.exs"
end
