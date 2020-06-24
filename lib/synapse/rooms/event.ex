defmodule ExMatrixApi.Synapse.Rooms.Event do
  @moduledoc """
  Event related to room timeline or invite.
  """

  defstruct content: nil,
            event_id: nil,
            origin_server_ts: nil,
            sender: nil,
            state_key: "",
            type: nil,
            unsigned: nil

  @state_types [
    "m.room.create",
    "m.room.name",
    "m.room.topic",
    "m.room.canonical_alias",
    "m.room.member"
  ]

  @supported_types @state_types ++
                     [
                       "m.room.aliases",
                       "m.room.message",
                       "m.room.join_rules"
                     ]

  @doc """
  Check if event is supported by this implementation.
  """
  @spec is_supported_type?(String.t()) :: boolean()
  def is_supported_type?(type) do
    type in @supported_types
  end

  @doc """
  Check if event is supported state event by this implementation.
  """
  @spec is_state_event?(String.t()) :: boolean()
  def is_state_event?(type) do
    type in @state_types
  end
end
