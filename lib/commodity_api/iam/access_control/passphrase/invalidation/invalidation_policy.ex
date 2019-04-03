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
defmodule Commodity.Api.Iam.AccessControl.Passphrase.InvalidationPolicy do
	use Commodity.Api, :policy

	alias Commodity.Api.Iam.User

	def options(_conn, _params, _type), do: true

	def create(conn, params, :self) do
		policy_query(conn, params["user_id"])
	end

	defp policy_query(conn, user_id) do
		case Repo.get(User, user_id) do
			nil ->
				true
			user ->
				user.id == conn.assigns[:user_id]
		end
	end
end