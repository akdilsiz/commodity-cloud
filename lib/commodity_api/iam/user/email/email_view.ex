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
defmodule Commodity.Api.Iam.User.EmailView do
	use Commodity.Api, :view

	def render("index.json", %{emails: emails}) do
		%{data: render_many(emails.all, __MODULE__, "email.json"),
		time_information: render_one(emails.time_information,
			Commodity.Api.Util.TimeInformationView,
			"time_information.json")}
	end

	def render("show.json", %{email: email}) do
		%{data: render_one(email.one, __MODULE__, "email.json"),
			time_information: render_one(email.time_information,
				Commodity.Api.Util.TimeInformationView,
				"time_information.json")}
	end

	def render("email.json", %{email: email}) do
		%{id: email.id,
		user_id: email.user_id,
		value: email.value,
		is_primary: if Map.get(email, :primary, false) do
			true
		else
			false
		end,
		inserted_at: to_datetime(email.inserted_at),
		updated_at: to_datetime(email.updated_at)}
	end
end