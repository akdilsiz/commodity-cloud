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
defmodule Commodity.Api.Iam.AccessControl.UserView do
	use Commodity.Api, :view

	def render("show.json", %{user: user}) do
		%{data: render_one(user.one, __MODULE__, "user.json"),
		time_information: render_one(user.time_information,
			TimeInformationView,
			"time_information.json")}
	end

	def render("user.json", %{user: user}) do
		%{id: user.id,
		personal_information: render_one(user.personal_information,
			Commodity.Api.Iam.User.PersonalInformationView,
			"personal_information.json"),
		emails: render_many(user.emails, 
			Commodity.Api.Iam.User.EmailView,
			"email.json"),
		phone_numbers: render_many(user.phone_numbers,
			Commodity.Api.Iam.User.PhoneNumberView,
			"phone_number.json"),
		inserted_at: NaiveDateTime.to_iso8601(user.inserted_at)}
	end
end