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
defmodule Commodity.Api.Iam.User.StateView do
	use Commodity.Api, :view

	def render("show.json", %{state: state}) do
		%{data: render_one(state.one, __MODULE__, "state.json"),
		time_information: render_one(state.time_information,
			TimeInformationView,
			"time_information.json")}
	end

	def render("state.json", %{state: state}) do
		%{id: state.id,
		user_id: state.user_id,
		state: state.state,
		note: state.note,
		inserted_at: to_datetime(state.inserted_at)}
	end
end