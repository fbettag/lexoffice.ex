defmodule LexOffice.Deserializer do
  @moduledoc """
  Helper functions for deserializing responses into models
  """

  @doc """
  Update the provided model with a deserialization of a nested value
  """
  @spec deserialize(struct(), :atom, :atom, struct(), keyword()) :: struct()
  def deserialize(model, field, :list, mod, options) do
    model
    |> Map.update!(field, &(Poison.Decode.decode(&1, Keyword.merge(options, [as: [struct(mod)]]))))
  end
  def deserialize(model, field, :struct, mod, options) do
    model
    |> Map.update!(field, &(Poison.Decode.decode(&1, Keyword.merge(options, [as: struct(mod)]))))
  end
  def deserialize(model, field, :map, mod, options) do
    model
    |> Map.update!(field, &(Map.new(&1, fn {key, val} -> {key, Poison.Decode.decode(val, Keyword.merge(options, [as: struct(mod)]))} end)))
  end
  def deserialize(model, field, :date, _, _options) do
    value = Map.get(model, field)
    case is_binary(value) do
      true -> case DateTime.from_iso8601(value) do
                {:ok, datetime, _offset} ->
                  Map.put(model, field, datetime)
                _ ->
                  model
              end
      false -> model
    end
  end
end
