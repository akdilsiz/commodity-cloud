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
defmodule Commodity.Api.Brand.DetailView do
	use Commodity.Api, :view

	def render("show.json", %{detail: detail}) do
		%{data: render_one(detail.one, __MODULE__, "detail.json"),
		time_information: render_one(detail.time_information,
			TimeInformationView, "time_information.json")}
	end

	def render("detail.json", %{detail: detail}) do
		%{id: detail.id,
		brand_id: detail.brand_id,
		name: detail.name,
		slug: detail.slug,
		inserted_at: to_datetime(detail.inserted_at)}
	end
end