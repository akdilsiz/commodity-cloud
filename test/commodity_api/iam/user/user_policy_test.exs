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
defmodule Commodity.Api.Iam.UserPolicyTest do
	use Commodity.ConnCase

	alias Commodity.Factory

	@moduletag login: :user_two

	test "should be 403 error, list all users with self permission",
		%{conn: conn, user: user} do
		permission_set = Repo.get_by!(PermissionSet, name: "Self")		
		Factory.insert(:permission_set_grant, user: user, target_user: user,
			permission_set: permission_set)

		conn = get conn, iam_user_path(conn, :index)

		assert conn.status == 403
	end

	test "show a user with self permission and given identifier",
		%{conn: conn, user: user} do
		permission_set = Repo.get_by!(PermissionSet, name: "Self")		
		Factory.insert(:permission_set_grant, user: user, target_user: user,
			permission_set: permission_set)

		state = Factory.insert(:user_state, user: user, value: "active")
		{:ok, "OK"} =
			Rediscl.Query.set("#{@redis_keys[:user].state}:#{user.id}",
				Jason.encode!(state))

		conn = get conn, iam_user_path(conn, :show, user.id)

		assert conn.status == 200
	end

	test "should be 403 error, show a user with self permission and other " <> 
		"user identifier",
		%{conn: conn, user: user} do
		permission_set = Repo.get_by!(PermissionSet, name: "Self")		
		Factory.insert(:permission_set_grant, user: user, target_user: user,
			permission_set: permission_set)

		user = Factory.insert(:user)
		state = Factory.insert(:user_state, user: user, value: "active")
		{:ok, "OK"} =
			Rediscl.Query.set("#{@redis_keys[:user].state}:#{user.id}",
				Jason.encode!(state))

		conn = get conn, iam_user_path(conn, :show, user.id)

		assert conn.status == 403
	end

	test "should be 403 error, create a user with self permission and " <>
		"valid params",
		%{conn: conn, user: user} do
		permission_set = Repo.get_by!(PermissionSet, name: "Self")		
		Factory.insert(:permission_set_grant, user: user, target_user: user,
			permission_set: permission_set)

		state = Factory.insert(:user_state, user: user, value: "active")
		{:ok, "OK"} =
			Rediscl.Query.set("#{@redis_keys[:user].state}:#{user.id}",
				Jason.encode!(state))

		conn = post conn, iam_user_path(conn, :create)

		assert conn.status == 403
	end

	test "should be 403 error, delete a user with self permission and given " <>
		"identifier",
		%{conn: conn, user: user} do
		permission_set = Repo.get_by!(PermissionSet, name: "Self")		
		Factory.insert(:permission_set_grant, user: user, target_user: user,
			permission_set: permission_set)

		state = Factory.insert(:user_state, user: user, value: "active")
		{:ok, "OK"} =
			Rediscl.Query.set("#{@redis_keys[:user].state}:#{user.id}",
				Jason.encode!(state))
			
		conn = delete conn, iam_user_path(conn, :delete, user.id)

		assert conn.status == 403
	end
end