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
defmodule Commodity.Api.Iam.UserView do
	use Commodity.Api, :view

	def render("index.json", %{users: users}) do
		%{data: render_many(users.all, __MODULE__, "user.json"),
		total_count: users.total_count,
		time_information: render_one(users.time_information,
			Commodity.Api.Util.TimeInformationView,
			"time_information.json")}
	end

	def render("show.json", %{user: user}) do
		%{data: render_one(user.one, __MODULE__, "user.json"),
		time_information: render_one(user.time_information,
			Commodity.Api.Util.TimeInformationView,
			"time_information.json")}
	end

	def render("user.json", %{user: user}) do
		%{id: user.id,
		personal_information: if !is_nil(Map.get(user, :personal_information, nil)) do
			render_one(user.personal_information,
				Commodity.Api.Iam.User.PersonalInformationView,
				"personal_information.json")
		else 
			nil
		end,
		emails: if !is_nil(Map.get(user, :emails, nil)) do
			render_many(user.emails, 
				Commodity.Api.Iam.User.EmailView,
				"email.json")
		else
			[]
		end,
		phone_numbers: if !is_nil(Map.get(user, :phone_numbers, nil)) do
			render_many(user.phone_numbers,
				Commodity.Api.Iam.User.PhoneNumberView,
				"phone_number.json")
		else
			[]
		end,
		inserted_at: to_datetime(user.inserted_at)}
	end
end