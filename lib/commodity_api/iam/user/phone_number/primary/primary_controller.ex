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
defmodule Commodity.Api.Iam.User.PhoneNumber.PrimaryController do
	use Commodity.Api, :controller

	alias Commodity.Api.Iam.User.PhoneNumber

	plug :authentication
	plug :authorized, [:all, :self]
	plug :apply_policy

	def options(conn, _params), do: send_resp(conn, :no_content, "")

	def create(conn, %{"user_id" => user_id, 
		"phone_number_id" => phone_number_id}) do
		phone_number = Repo.get_by!(PhoneNumber, id: phone_number_id, 
			user_id: user_id)

		changeset = PhoneNumber.Primary.changeset(%PhoneNumber.Primary{},
			%{number_id: phone_number.id, user_id: phone_number.user_id, 
			source_user_id: conn.assigns[:user_id]})

		{:ok, _primary} = Repo.transaction(fn -> 
			primary = Repo.insert!(changeset)

			{:ok, "OK"} = 
				Rediscl.Query.set("#{@redis_keys[:user].phone_number.primary}:" <>
					"#{user_id}", primary.number_id)

			primary
		end)

		send_resp(conn, :created, "")
	end
end