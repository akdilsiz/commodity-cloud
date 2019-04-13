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
defmodule Commodity.Api.Iam.User.PasswordAssignmentController do
	use Commodity.Api, :controller

	import Ecto.Changeset, only: [get_field: 2, add_error: 3]
	import Comeonin.Bcrypt, only: [checkpw: 2]

	alias Commodity.Api.Iam.User.PasswordAssignment

	plug :authentication
	plug :authorized, [:all, :self]
	plug :apply_policy
	plug :scrub_params, "password_assignment" when action in [:create]

	def options(conn, _params), do: send_resp(conn, :no_content, "")

	def create(conn, %{"user_id" => user_id, 
		"password_assignment" => password_assignment_params}) do
		password_assignment_params = 
			Map.put(password_assignment_params, "user_id", user_id)
			|> Map.put("source_user_id", conn.assigns[:user_id])

		changeset = PasswordAssignment.changeset(%PasswordAssignment{},
			password_assignment_params)

		transaction = Repo.transaction(fn -> 
			unless changeset.valid? do
				Repo.rollback(changeset)
			end
			
			query = from upa in PasswordAssignment,
							where: upa.user_id == ^user_id,
							limit: 3,
							order_by: [desc: :id],
							select: upa.password_digest

			password_digests = Repo.all(query)

			if Enum.any?(password_digests, 
				&checkpw(get_field(changeset, :password), &1)) do
				Repo.rollback(add_error(changeset, :password, 
					"Enter a different password from the last three password."))
			end

			{status, password_assignment} = Repo.insert(changeset)

			if status == :error do
				Repo.rollback(password_assignment)
			end

			{:ok, "OK"} =
				Rediscl.Query.set("#{@redis_keys[:user].password_assignment.one}:" <>
					"#{user_id}", Jason.encode!(password_assignment))

			password_assignment
		end)

		case transaction do
			{:ok, _password_assignment} ->
				send_resp(conn, :created, "")
			{:error, changeset} ->
				conn
				|> put_status(:unprocessable_entity)
				|> put_view(ChangesetView)
				|> render("error.json", changeset: changeset)
		end
	end
end