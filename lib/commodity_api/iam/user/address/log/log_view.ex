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
defmodule Commodity.Api.Iam.User.Address.LogView do
	use Commodity.Api, :view

	def render("index.json", %{logs: logs}) do
		%{data: render_many(logs.all, __MODULE__, "log.json"),
		total_count: logs.total_count,
		time_information: render_one(logs.time_information,
			TimeInformationView,
			"time_information.json")}
	end

	def render("log.json", %{log: log}) do
		%{id: log.id,
		user_id: log.user_id,
		address_id: log.address_id,
		inserted_at: NaiveDateTime.to_iso8601(log.inserted_at)}
	end
end