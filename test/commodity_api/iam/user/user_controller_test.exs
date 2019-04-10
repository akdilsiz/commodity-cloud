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
defmodule Commodity.Api.Iam.UserControllerTest do
	use Commodity.ConnCase

	alias Commodity.Factory

	@moduletag login: :user

	setup %{conn: conn, user: user} do
		permission_set = Repo.get_by!(PermissionSet, name: "Superadmin")
		Factory.insert(:permission_set_grant, user: user, target_user: user,
			permission_set: permission_set)

		%{conn: conn, user: user}
	end

	test "options/0", %{conn: conn} do
		conn = options conn, iam_user_path(conn, :index)

		assert conn.status == 204
	end

	test "options/1", %{conn: conn} do
		conn = options conn, iam_user_path(conn, :show, 1)

		assert conn.status == 204
	end	

	test "list all users", %{conn: conn} do
		Factory.insert_list(10, :user)
		|> Enum.map(fn x -> 
			Factory.insert(:user_state, user: x, source_user: x,
				value: "active")
		end)

		conn = get conn, iam_user_path(conn, :index)

		data = json_response(conn, 200)

		assert data["total_count"] >= 10
		assert data["time_information"]
		assert Enum.count(data["data"]) >= 10
	end
end