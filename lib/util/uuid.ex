defmodule ExMatrixApi.Util.UUID do
  @moduledoc """
  Wrapper for uuid generation
  """

  alias ExMatrixApi.Synapse

  @spec generate :: String.t()
  def generate() do
    uuid_function = Synapse.config!(:uuid_function)

    apply(uuid_function, [])
  end
end
