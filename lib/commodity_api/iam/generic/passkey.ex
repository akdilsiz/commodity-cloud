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
defmodule Commodity.Api.Iam.Generic.Passkey do
	@moduledoc """
	Property representing the secure data of an access token.
	A passkey is simply a concatenation of four UUIDs (Version 4).
	"""

	@doc """
	Generates a string passkey with an absolute length of given part size and
	padding.
	"""
	@spec generate(integer, boolean) :: String.t
	def generate(uuid_part, padding) when is_boolean(padding) do
		Base.encode64(bingenerate(uuid_part), padding: padding)
	end

	@doc """
	Generates a string passkey with an absolute length of 192 with padding.
	"""
	@spec generate(boolean) :: String.t
	def generate(padding) when is_boolean(padding) do
		Base.encode64(bingenerate(), padding: padding)
	end

	@doc """
	Generates a string passkey with an absolute length of given part size.
	"""
	@spec generate(integer) :: String.t
	def generate(uuid_part) do
		Base.encode64(bingenerate(uuid_part), padding: true)
	end

	@doc """
	Generates a string passkey with an absolute length of 192.
	"""
	@spec generate() :: String.t
	def generate() do
		Base.encode64(bingenerate(), padding: true)
	end

	@doc """
	Generates a binary passkey with given part size.
	"""
	@spec bingenerate(integer) :: binary
	def bingenerate(uuid_part) do
		Enum.map_join(1..uuid_part, fn(_) -> Ecto.UUID.bingenerate() end)
	end

	@doc """
	Generates a binary passkey.
	"""
	@spec bingenerate() :: binary
	def bingenerate() do
		Enum.map_join(1..9, fn(_) -> Ecto.UUID.bingenerate() end)
	end
end