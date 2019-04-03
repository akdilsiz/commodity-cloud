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
defmodule Commodity.Api.Generic.BaseArtifactsGenerate do
	@moduledoc false
	
	alias Commodity.Elastic

	#@redis_keys Application.get_env(:commodity, :redis_keys)
	@elasticsearch Application.get_env(:commodity, :elasticsearch)

	def clean_and_generate(repo) do
		clean(repo)
		generate(repo)
	end

	defp clean(_repo) do
		{:ok, _} = Elastic.delete("/user")
	end

	defp generate(_repo) do
		{:ok, _} = Elastic.put("/user", @elasticsearch[:settings], :put)

		{:ok, _} = Elastic.put("/user/_mapping/_doc", 
			@elasticsearch[:mappings].user, :put)
	end
end