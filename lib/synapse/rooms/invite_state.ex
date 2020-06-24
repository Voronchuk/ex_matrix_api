defmodule ExMatrixApi.Synapse.Rooms.InviteState do
  @moduledoc """
  State of room invite in scope of events.
  """

  defstruct uid: nil,
            events: []
end
