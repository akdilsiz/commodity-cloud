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
defmodule Commodity.Api.Iam.AccessControl.Passphrase.InvalidationView do
	use Commodity.Api, :view

	def render("show.json", %{invalidation: invalidation}) do
		%{data: render_one(invalidation.one, __MODULE__, "invalidation.json"),
		time_information: render_one(invalidation.time_information,
			Commodity.Api.Util.TimeInformationView,
			"time_information.json")}
	end

	def render("invalidation.json", %{invalidation: invalidation}) do
		%{passphrase_ids: invalidation.passphrase_ids}
	end
end