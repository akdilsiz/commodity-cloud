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
defmodule Commodity.Api.Iam.User.PhoneNumberView do
	use Commodity.Api, :view

	def render("index.json", %{phone_numbers: phone_numbers}) do
		%{data: render_many(phone_numbers.all, __MODULE__, "phone_number.json"),
		total_count: phone_numbers.total_count,
		time_information: render_one(phone_numbers.time_information,
			Commodity.Api.Util.TimeInformationView,
			"time_information.json")}
	end

	def render("show.json", %{phone_number: phone_number}) do
		%{data: render_one(phone_number.one, __MODULE__, "phone_number.json"),
		time_information: render_one(phone_number.time_information,
			Commodity.Api.Util.TimeInformationView,
			"time_information.json")}
	end

	def render("phone_number.json", %{phone_number: phone_number}) do
		%{id: phone_number.id,
		user_id: phone_number.user_id,
		value: phone_number.value,
		type: phone_number.type,
		is_primary: if Map.get(phone_number, :primary, false) do
			true
		else
			false
		end,
		inserted_at: to_datetime(phone_number.inserted_at),
		updated_at: to_datetime(phone_number.updated_at)}
	end
end