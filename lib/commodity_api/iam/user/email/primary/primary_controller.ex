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
defmodule Commodity.Api.Iam.User.Email.PrimaryController do
	use Commodity.Api, :controller

	alias Commodity.Api.Iam.User.Email

	plug :authentication
	plug :authorized, [:all, :self]
	plug :apply_policy

	def options(conn, _params), do: send_resp(conn, :no_content, "")

	def create(conn, %{"user_id" => user_id, "email_id" => email_id}) do
		email = Repo.get_by!(Email, id: email_id, user_id: user_id)

		changeset = Email.Primary.changeset(%Email.Primary{},
			%{email_id: email.id, user_id: email.user_id, 
			source_user_id: conn.assigns[:user_id]})

		{:ok, _primary} = Repo.transaction(fn -> 
			primary = Repo.insert!(changeset)

			{:ok, "OK"} = 
				Rediscl.Query.set("#{@redis_keys[:user].email.primary}:#{user_id}",
					primary.email_id)

			primary
		end)

		send_resp(conn, :created, "")
	end
end