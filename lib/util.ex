defmodule ExMatrixApi.Util do
  @moduledoc """
  Generic helper functions.
  """

  @spec to_struct(module, map) :: struct
  @doc """
  Same as &Kernel.struct/2, but works for string keys.
  """
  def to_struct(kind, attrs) when is_atom(kind) and is_map(attrs) do
    struct = struct(kind)

    Enum.reduce(Map.to_list(struct), struct, fn {k, _}, acc ->
      case Map.fetch(attrs, Atom.to_string(k)) do
        {:ok, v} -> %{acc | k => v}
        :error -> acc
      end
    end)
  end

  @doc """
  Converts list to list of structs
  """
  @spec to_struct(List.t(), module) :: struct
  def to_struct(list, mod) when is_list(list) and is_atom(mod),
    do: Enum.map(list, &to_struct(mod, &1))

  @doc """
  Converts nested maps to given struct
  """
  @spec to_struct(map, atom, module) :: struct
  def to_struct(map, key, mod) when is_map(map) and is_atom(key) and is_atom(mod),
    do: Map.update!(map, key, &to_struct(mod, &1))
end
