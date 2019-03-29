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
defmodule Commodity.Api.Util.Type.DateTime do
	@moduledoc """
	Commodity API DateTime
	"""

	@doc """
	To ISO 8601 Format given datetime string
	"""
	@spec to_datetime(binary | NaiveDateTime.t) :: NaiveDateTime.t | binary
	def to_datetime(datetime) do
		case Typeable.typeof(datetime) do
			"naivedatime" ->
				NaiveDateTime.to_iso8601(datetime)
			"string" ->
				{:ok, naive_datetime} = NaiveDateTime.from_iso8601(datetime)

				NaiveDateTime.to_iso8601(naive_datetime)
			_ ->
				NaiveDateTime.utc_now
		end
	end
end