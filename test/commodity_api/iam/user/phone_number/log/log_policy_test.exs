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
defmodule Commodity.Api.Iam.User.PhoneNumber.LogPolicyTest do
	use Commodity.ConnCase

	alias Commodity.Factory

	@moduletag login: :user_two

	test "list all user phone_number logs with given identifiers and " <>
		"self permission", %{conn: conn, user: user} do
		permission_set = Repo.get_by!(PermissionSet, name: "Self")		
		Factory.insert(:permission_set_grant, user: user, target_user: user,
			permission_set: permission_set)

		phone_number = Factory.insert(:user_phone_number, user: user)

		conn = 
			get conn, iam_user_phone_number_log_path(conn, :index, user.id, 
				phone_number.id)

		assert conn.status == 200
	end

	test "should be 403 error list all user phone_number logs with " <>
		"given identifiers(other user identifier) and self permission",
		%{conn: conn, user: user} do
		permission_set = Repo.get_by!(PermissionSet, name: "Self")		
		Factory.insert(:permission_set_grant, user: user, target_user: user,
			permission_set: permission_set)

		user = Factory.insert(:user)
		phone_number = Factory.insert(:user_phone_number, user: user)

		conn = 
			get conn, iam_user_phone_number_log_path(conn, :index, user.id, 
				phone_number.id)

		assert conn.status == 403
	end
end