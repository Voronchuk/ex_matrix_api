defmodule ExMatrixApi.Util.Request do
  @moduledoc """
  Utility wrapper for making HTTP requests.

  Delegates to the configured HTTP client module.
  """
  use UtilsHttp.Behaviour.HttpClient, http_client: ExMatrixApi.Synapse.config!(:http_client)
end
