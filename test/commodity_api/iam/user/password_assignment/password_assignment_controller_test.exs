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
defmodule Commodity.Api.Iam.User.PasswordAssignmentControllerTest do
	use Commodity.ConnCase

	import Comeonin.Bcrypt, only: [hashpwsalt: 1]

	alias Commodity.Factory

	@moduletag login: :user

	setup %{conn: conn, user: user} do
		permission_set = Repo.get_by!(PermissionSet, name: "Superadmin")
		Factory.insert(:permission_set_grant, user: user, target_user: user,
			permission_set: permission_set)

		%{conn: conn, user: user}
	end

	test "options/1", %{conn: conn} do
		conn = options conn, iam_user_password_assignment_path(conn, :create, 1)

		assert conn.status == 204
	end

	test "create a user password assignment with given identifier and " <>
		"valid params", %{conn: conn} do
		user = Factory.insert(:user)		

		conn = 
			post conn, iam_user_password_assignment_path(conn, :create, user.id),
			password_assignment: %{password: "123456789"}

		assert conn.status == 201

		assert {:ok, cached_password_assignment} =
			Rediscl.Query.get("#{@redis_keys[:user].password_assignment.one}:#{user.id}")

		cached_password_assignment = 
			Jason.decode!(cached_password_assignment, [{:keys, :atoms!}])

		assert cached_password_assignment.id
		assert cached_password_assignment.user_id == user.id
		assert cached_password_assignment.password_digest
		assert cached_password_assignment.inserted_at
	end

	test "should be 422 error create a user password assignment with given " <>
		"identifier and invalid params", %{conn: conn} do
		user = Factory.insert(:user)		

		conn = 
			post conn, iam_user_password_assignment_path(conn, :create, user.id),
			password_assignment: %{password: false}

		assert conn.status == 422
	end

	test "should be 422 error create a user password assignment with invalid " <>
		"identifier and invalid params", %{conn: conn} do
		conn = 
			post conn, iam_user_password_assignment_path(conn, :create, 99_999_999),
			password_assignment: %{password: "123456789"}

		assert conn.status == 422
	end

	test "should be 422 error create a user password assignment with given " <>
		"identifier and valid params if password not different last three password", 
		%{conn: conn} do
		user = Factory.insert(:user)		

		Factory.insert(:user_password_assignment, user: user,
			password_digest: hashpwsalt("123456789"))
		Factory.insert(:user_password_assignment, user: user,
			password_digest: hashpwsalt("123456789a"))
		Factory.insert(:user_password_assignment, user: user,
			password_digest: hashpwsalt("123456789b"))

		conn = 
			post conn, iam_user_password_assignment_path(conn, :create, user.id),
			password_assignment: %{password: "123456789a"}

		assert conn.status == 422

		data = json_response(conn, 422)

		assert data["errors"]["changeset"]["password"] ==
			["Enter a different password from the last three password."]
	end
end