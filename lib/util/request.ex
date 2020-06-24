defmodule ExMatrixApi.Util.Request do
  @moduledoc """
  Utility wrapper for making HTTP requests.

  Delegates to the configured HTTP client module.
  """
  use ExMatrixApi.Behaviour.HttpClient
end
