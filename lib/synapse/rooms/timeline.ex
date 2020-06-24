defmodule ExMatrixApi.Synapse.Rooms.Timeline do
  @moduledoc """
  Timeline of events in scope of room.
  """

  defstruct uid: nil,
            events: [],
            state_events: [],
            limited: false,
            prev_batch: nil,
            next_batch: nil
end
