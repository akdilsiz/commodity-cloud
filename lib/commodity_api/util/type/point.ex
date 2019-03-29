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
defmodule Commodity.Api.Util.Type.Point do
	@behaviour Ecto.Type
	def type, do: Postgrex.Point

	@doc "Casting from input into point struct"
	def cast(value = %Postgrex.Point{}), do: {:ok, value}
	def cast(%{x: x, y: y}) do
		{:ok, %Postgrex.Point{x: x, y: y}}
	end
	def cast(%{"x" => x, "y" => y}) do
		{:ok, %Postgrex.Point{x: x, y: y}}
	end
	def cast(%{lat: x, long: y}) do
		{:ok, %Postgrex.Point{x: x, y: y}}
	end
	def cast(%{"lat" => x, "long" => y}) do
		{:ok, %Postgrex.Point{x: x, y: y}}
	end
	def cast(_), do: :error

	@doc "loading data from the database"
	def load(data) do
		{:ok, data}
	end

	@doc "dumping data to the database"
	def dump(value = %Postgrex.Point{}), do: {:ok, value}
	def dump(_), do: :error

	def decode(%Postgrex.Point{x: x, y: y}) do
		"#{x},#{y}"
	end
end

defimpl Jason.Encoder, for: [Postgrex.Point] do
  def encode(struct, opts) do
  	Jason.Encode.map(%{x: struct.x, y: struct.y}, opts)
  end
end

defimpl String.Chars, for: Postgrex.Point do
  def to_string(%Postgrex.Point{} = point), do: Commodity.Api.Util.Type.Point.decode(point)
end