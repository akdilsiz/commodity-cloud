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
defmodule Commodity.Api.BrandView do
	use Commodity.Api, :view

	def render("index.json", %{brands: brands}) do
		%{data: render_many(brands.all, __MODULE__, "brand.json"),
		total_count: brands.total_count,
		time_information: render_one(brands.time_information,
			TimeInformationView,
			"time_information.json")}
	end

	def render("show.json", %{brand: brand}) do
		%{data: render_one(brand.one, __MODULE__, "brand.json"),
		time_information: render_one(brand.time_information,
			TimeInformationView,
			"time_information.json")}
	end

	def render("brand.json", %{brand: brand}) do
		%{id: brand.id,
		detail: case Map.get(brand, :detail, nil) do
			nil ->
				nil
			detail ->
				render_one(detail, Commodity.Api.Brand.DetailView, "detail.json")
		end,
		inserted_at: to_datetime(brand.inserted_at)}
	end
end