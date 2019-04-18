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
defmodule Commodity.Api.Iam.User.PhoneNumber.LogControllerTest do
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
		conn = options conn, iam_user_phone_number_log_path(conn, :index, 1, 1)

		assert conn.status == 204
	end

	test "list all user phone_number logs with given identifiers", %{conn: conn} do
		user = Factory.insert(:user)
		phone_number = Factory.insert(:user_phone_number, user: user)

		Factory.insert_list(50, :user_phone_number_log, user: user, 
			number: phone_number)

		conn = 
			get conn, iam_user_phone_number_log_path(conn, :index, user.id, 
				phone_number.id)

		data = json_response(conn, 200)

		assert data["time_information"]
		assert data["total_count"] == 50
		assert Enum.count(data["data"]) == 50
	end
end