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
defmodule Commodity.Api.Iam.AccessControl.PassphraseView do
	use Commodity.Api, :view

	def render("show.json", %{passphrase: passphrase}) do
		%{data: render_one(passphrase.one, __MODULE__, "passphrase.json"),
		time_information: render_one(passphrase.time_information,
			Commodity.Api.Util.TimeInformationView,
			"time_information.json")}
	end

	def render("passphrase.json", %{passphrase: passphrase}) do
		%{id: passphrase.id,
			user_id: passphrase.user_id,
			passphrase: passphrase.passphrase,
			inserted_at: NaiveDateTime.to_iso8601(passphrase.inserted_at)}
	end
end