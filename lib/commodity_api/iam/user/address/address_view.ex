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
defmodule Commodity.Api.Iam.User.AddressView do
	use Commodity.Api, :view

	def render("index.json", %{addresses: addresses}) do
		%{data: render_many(addresses.all, __MODULE__, "address.json"),
		total_count: addresses.total_count,
		time_information: render_one(addresses.time_information,
			TimeInformationView,
			"time_information.json")}
	end

	def render("show.json", %{address: address}) do
		%{data: render_one(address.one, __MODULE__, "address.json"),
		time_information: render_one(address.time_information,
			TimeInformationView,
			"time_information.json")}
	end

	def render("address.json", %{address: address}) do
		%{id: address.id,
		user_id: address.user_id,
		type: address.type,
		name: address.name,
		country: address.country,
		state: address.state,
		city: address.city,
		zip_code: address.zip_code,
		address: address.address,
		inserted_at: to_datetime(address.inserted_at),
		updated_at: to_datetime(address.updated_at)}
	end
end