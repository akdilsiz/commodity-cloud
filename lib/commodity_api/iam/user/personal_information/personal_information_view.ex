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
defmodule Commodity.Api.Iam.User.PersonalInformationView do
	use Commodity.Api, :view

	def render("show.json", %{personal_information: personal_information}) do
		%{data: render_one(personal_information.one, __MODULE__, 
				"personal_information.json"),
		time_information: render_one(personal_information.time_information,
			Commodity.Api.Util.TimeInformationView,
			"time_information.json")}
	end

	def render("personal_information.json", 
		%{personal_information: personal_information}) do
		%{id: personal_information.id,
		user_id: personal_information.user_id,
		given_name: personal_information.given_name,
		family_name: personal_information.family_name,
		gender: personal_information.gender,
		nationality: personal_information.nationality,
		birthday: personal_information.birthday,
		inserted_at: to_datetime(personal_information.inserted_at)}		
	end
end