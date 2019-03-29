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
defmodule Commodity.Api.Generic.CleanThirdpartyDb do
	@moduledoc """
	Clean Third-Party DB systems
	"""
	alias Commodity.Elastic

	def clean_and_generate do
		clean()
	end

	defp clean do
		# Clean Redis Db
		Rediscl.Query.command("FLUSHDB")

		# Find a elastic indexes and remove indexes
		Elastic.get("/_mapping")
		|> elem(1)
		|> Map.keys
		|> Enum.each(fn x -> {:ok, _} = Elastic.delete("/" <> x) end)
	end
end