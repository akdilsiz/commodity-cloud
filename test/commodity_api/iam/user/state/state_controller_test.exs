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
defmodule Commodity.Api.Iam.User.StateControllerTest do
	use Commodity.ConnCase

	alias Commodity.Factory

	@moduletag login: :user

	setup %{conn: conn, user: user} do
		permission_set = Repo.get_by!(PermissionSet, name: "Superadmin")
		Factory.insert(:permission_set_grant, user: user, target_user: user,
			permission_set: permission_set)

		%{conn: conn, user: user}
	end

	test "options/1", %{conn: conn} do
		conn = options conn, iam_user_state_path(conn, :create, 1)

		assert conn.status == 204
	end

	test "create a user state with given identifier and valid params",
		%{conn: conn} do
		user = Factory.insert(:user)			

		conn =
			post conn, iam_user_state_path(conn, :create, user.id),
			state: %{value: "active", note: "First active"}

		data = json_response(conn, 201)

		assert data["time_information"]

		data = data["data"]

		assert data["id"]
		assert data["user_id"] == user.id
		assert data["value"] == "active"
		assert data["note"] == "First active"
		assert data["inserted_at"]

		assert {:ok, cached_state} =
			Rediscl.Query.get("#{@redis_keys[:user].state}:#{user.id}")

		cached_state = Jason.decode!(cached_state, [{:keys, :atoms!}])

		assert cached_state.id == data["id"]
		assert cached_state.user_id == user.id
		assert cached_state.value == "active"
		assert cached_state.note == "First active"
		assert cached_state.inserted_at == data["inserted_at"]
	end

	test "should be 422 error create a user state with given identifier and " <>
		"invalid params", %{conn: conn} do
		user = Factory.insert(:user)

		conn =
		 	post conn, iam_user_state_path(conn, :create, user.id),
		 	state: %{value: "unknown"}

	 	assert conn.status == 422
	end
end