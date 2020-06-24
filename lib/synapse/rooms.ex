defmodule ExMatrixApi.Synapse.Rooms do
  @moduledoc """
  Batch of room events.
  """

  defstruct invite: %{},
            join: %{},
            leave: %{}
end
