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
defmodule Commodity.Api.Generic.TimeInformationPlug do
	@moduledoc """
	Timeinformation plug
	"""

	import Plug.Conn, only: [assign: 3]

	def init(default), do: default

	def call(conn, _opts) do
		conn
		|> assign(:time_information, 
				%{zone: "UTC",
				timestamp: NaiveDateTime.to_iso8601(NaiveDateTime.utc_now)})
	end
end