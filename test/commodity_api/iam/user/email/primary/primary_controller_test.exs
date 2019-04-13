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
defmodule Commodity.Api.Iam.User.Email.PrimaryControllerTest do
	use Commodity.ConnCase

	alias Commodity.Factory

	@moduletag login: :user

	setup %{conn: conn, user: user} do
		permission_set = Repo.get_by!(PermissionSet, name: "Superadmin")
		Factory.insert(:permission_set_grant, user: user, target_user: user,
			permission_set: permission_set)

		%{conn: conn, user: user}
	end

	test "options/2", %{conn: conn} do
		conn = options conn, iam_user_email_primary_path(conn, :create, 1, 1)

		assert conn.status == 204
	end

	test "create a user email primary with given identifiers", %{conn: conn} do
		user = Factory.insert(:user)
		email = Factory.insert(:user_email, user: user)

		conn = 
			post conn, iam_user_email_primary_path(conn, :create, user.id, email.id)

		assert conn.status == 201
	end

	test "should be 422 error create a user email primary with given " <>
		"identifiers if user email primary already taken", %{conn: conn} do
		user = Factory.insert(:user)		
		email = Factory.insert(:user_email, user: user)

		Factory.insert(:user_email_primary, user: user, email: email)

		assert_error_sent 422, fn -> 
			post conn, iam_user_email_primary_path(conn, :create, user.id, email.id)
		end
	end
end