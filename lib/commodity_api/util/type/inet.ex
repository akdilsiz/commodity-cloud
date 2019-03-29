##
#    Copyright 2018 Abdulkadir DILSIZ
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
## 
defmodule Commodity.Api.Util.Type.INET do
  @moduledoc ~S"""
  Support for using Ecto with :inet fields
  """

  @behaviour Ecto.Type

  def type, do: :inet

  @doc """
  Handle casting to Postgrex.INET
  """
  def cast(%Postgrex.INET{} = address), do: {:ok, address}
  def cast(address) when is_binary(address) do
    case parse_address(address) do
      {:ok, parsed_address} -> {:ok, %Postgrex.INET{address: parsed_address}}
      {:error, _einval}     -> :error
    end
  end
  def cast(_), do: :error

  @doc """
  Load from the native Ecto representation
  """
  def load(%Postgrex.INET{} = address), do: {:ok, address}
  def load(_), do: :error

  @doc """
  Convert to the native Ecto representation
  """
  def dump(%Postgrex.INET{} = address), do: {:ok, address}
  def dump(_), do: :error

  @doc """
  Convert from native Ecto representation to a binary
  """
  def decode(%Postgrex.INET{address: address}) do
    case :inet.ntoa(address) do
      {:error, _einval} -> :error
      formatted_address  -> List.to_string(formatted_address)
    end
  end

  defp parse_address(address) do
    address |> String.to_charlist |> :inet.parse_address
  end
end

defimpl String.Chars, for: Postgrex.INET do
  def to_string(%Postgrex.INET{} = address), do: Commodity.Api.Util.Type.INET.decode(address)
end
