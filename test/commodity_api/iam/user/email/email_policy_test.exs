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
defmodule Commodity.Api.Iam.User.EmailPolicyTest do
	use Commodity.ConnCase

	alias Commodity.Factory

	@moduletag login: :user_two

	test "list all user emails with given identifier and self permission",
		%{conn: conn, user: user} do
		permission_set = Repo.get_by!(PermissionSet, name: "Self")		
		Factory.insert(:permission_set_grant, user: user, target_user: user,
			permission_set: permission_set)

		conn = get conn, iam_user_email_path(conn, :index, user.id)

		assert conn.status == 200
	end

	test "should be 403 error list all user emails with other user identifier" <>
		" and self permission",
		%{conn: conn, user: user} do
		permission_set = Repo.get_by!(PermissionSet, name: "Self")		
		Factory.insert(:permission_set_grant, user: user, target_user: user,
			permission_set: permission_set)

		user = Factory.insert(:user)

		conn = get conn, iam_user_email_path(conn, :index, user.id)

		assert conn.status == 403
	end

	test "show a user email with given identifiers and self permission",
		%{conn: conn, user: user} do
		permission_set = Repo.get_by!(PermissionSet, name: "Self")		
		Factory.insert(:permission_set_grant, user: user, target_user: user,
			permission_set: permission_set)

		email = Factory.insert(:user_email, user: user)

		conn = get conn, iam_user_email_path(conn, :show, user.id, email.id)

		assert conn.status == 200
	end

	test "should be 403 error show a user email with given identifiers " <>
		"(other user identifier) and self permission",
		%{conn: conn, user: user} do
		permission_set = Repo.get_by!(PermissionSet, name: "Self")		
		Factory.insert(:permission_set_grant, user: user, target_user: user,
			permission_set: permission_set)

		user = Factory.insert(:user)
		email = Factory.insert(:user_email, user: user)

		conn = get conn, iam_user_email_path(conn, :show, user.id, email.id)

		assert conn.status == 403
	end

	test "create a user email with given identifier, valid params and self " <>
		"permission",
		%{conn: conn, user: user} do
		permission_set = Repo.get_by!(PermissionSet, name: "Self")		
		Factory.insert(:permission_set_grant, user: user, target_user: user,
			permission_set: permission_set)

		conn = 
			post conn, iam_user_email_path(conn, :create, user.id),
			email: %{value: "email@email.com"}

		assert conn.status == 201
	end

	test "should be 403 create a user email with other user identifier, " <>
		"valid params and self permission", %{conn: conn, user: user} do
		permission_set = Repo.get_by!(PermissionSet, name: "Self")		
		Factory.insert(:permission_set_grant, user: user, target_user: user,
			permission_set: permission_set)

		user = Factory.insert(:user)

		conn = 
			post conn, iam_user_email_path(conn, :create, user.id),
			email: %{value: "email@email.com"}

		assert conn.status == 403
	end

	test "replace a user email with given identifier, valid params and self " <>
		"permission",
		%{conn: conn, user: user} do
		permission_set = Repo.get_by!(PermissionSet, name: "Self")		
		Factory.insert(:permission_set_grant, user: user, target_user: user,
			permission_set: permission_set)

		email = Factory.insert(:user_email, user: user)

		{:ok, "1"} = 
			Rediscl.Query.sadd("#{@redis_keys[:user].email.all}:#{user.id}",
				[Jason.encode!(email)])

		conn = 
			put conn, iam_user_email_path(conn, :update, user.id, email.id),
			email: %{value: "email@email.com"}

		assert conn.status == 200
	end

	test "should be 403 error replace a user email with other user identifier, " <>
		"valid params and self permission",
		%{conn: conn, user: user} do
		permission_set = Repo.get_by!(PermissionSet, name: "Self")		
		Factory.insert(:permission_set_grant, user: user, target_user: user,
			permission_set: permission_set)

		user = Factory.insert(:user)
		email = Factory.insert(:user_email, user: user)

		conn = 
			put conn, iam_user_email_path(conn, :update, user.id, email.id),
			email: %{value: "email@email.com"}

		assert conn.status == 403
	end

	test "delete a user email with given identifier and self permission",
		%{conn: conn, user: user} do
		permission_set = Repo.get_by!(PermissionSet, name: "Self")		
		Factory.insert(:permission_set_grant, user: user, target_user: user,
			permission_set: permission_set)

		email = Factory.insert(:user_email, user: user)

		{:ok, "1"} = 
			Rediscl.Query.sadd("#{@redis_keys[:user].email.all}:#{user.id}",
				[Jason.encode!(email)])

		{:ok, "OK"} =
			Rediscl.Query.set("#{@redis_keys[:user].email.one}:#{user.id}:#{email.id}",
				Jason.encode!(email))

		conn = 
			delete conn, iam_user_email_path(conn, :delete, user.id, email.id)

		assert conn.status == 204
	end

	test "should be 403 error delete a user email with other user identifier and 
		self permission",
		%{conn: conn, user: user} do
		permission_set = Repo.get_by!(PermissionSet, name: "Self")		
		Factory.insert(:permission_set_grant, user: user, target_user: user,
			permission_set: permission_set)

		user = Factory.insert(:user)
		email = Factory.insert(:user_email, user: user)

		conn = 
			delete conn, iam_user_email_path(conn, :delete, user.id, email.id)

		assert conn.status == 403
	end	
end