defmodule ExMatrixApi.Synapse.AccountData.Event do
  @moduledoc """
  Event related to account.
  """

  @enforce_keys [:type]
  defstruct content: nil,
            type: nil
end
