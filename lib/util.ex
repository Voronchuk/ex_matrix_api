defmodule ExMatrixApi.Util do
  @moduledoc """
  Generic helper functions.
  """

  @doc """
  Same as &Kernel.struct/2, but works for string keys.
  """
  def to_struct(kind, attrs) do
    struct = struct(kind)

    Enum.reduce(Map.to_list(struct), struct, fn {k, _}, acc ->
      case Map.fetch(attrs, Atom.to_string(k)) do
        {:ok, v} -> %{acc | k => v}
        :error -> acc
      end
    end)
  end
end
