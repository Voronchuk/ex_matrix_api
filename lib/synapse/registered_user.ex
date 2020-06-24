defmodule ExMatrixApi.Synapse.RegisteredUser do
  @moduledoc """
  Newly registered user with auth token.
  """

  defstruct user_id: nil,
            device_id: nil,
            access_token: nil
end
