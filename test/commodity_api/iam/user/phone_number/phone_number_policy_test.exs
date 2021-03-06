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
defmodule Commodity.Api.Iam.User.PhoneNumberPolicyTest do
	use Commodity.ConnCase

	alias Commodity.Factory

	@moduletag login: :user_two

	test "list all user phone_numbers with given identifier and self permission",
		%{conn: conn, user: user} do
		permission_set = Repo.get_by!(PermissionSet, name: "Self")		
		Factory.insert(:permission_set_grant, user: user, target_user: user,
			permission_set: permission_set)

		conn = get conn, iam_user_phone_number_path(conn, :index, user.id)

		assert conn.status == 200
	end

	test "should be 403 error list all user phone_numbers with other " <>
		"user identifier and self permission",
		%{conn: conn, user: user} do
		permission_set = Repo.get_by!(PermissionSet, name: "Self")		
		Factory.insert(:permission_set_grant, user: user, target_user: user,
			permission_set: permission_set)

		user = Factory.insert(:user)

		conn = get conn, iam_user_phone_number_path(conn, :index, user.id)

		assert conn.status == 403
	end

	test "show a user phone_number with given identifiers and self permission",
		%{conn: conn, user: user} do
		permission_set = Repo.get_by!(PermissionSet, name: "Self")		
		Factory.insert(:permission_set_grant, user: user, target_user: user,
			permission_set: permission_set)

		phone_number = Factory.insert(:user_phone_number, user: user)

		conn = 
			get conn, iam_user_phone_number_path(conn, :show, user.id, 
				phone_number.id)

		assert conn.status == 200
	end

	test "should be 403 error show a user phone_number with given identifiers " <>
		"(other user identifier) and self permission",
		%{conn: conn, user: user} do
		permission_set = Repo.get_by!(PermissionSet, name: "Self")		
		Factory.insert(:permission_set_grant, user: user, target_user: user,
			permission_set: permission_set)

		user = Factory.insert(:user)
		phone_number = Factory.insert(:user_phone_number, user: user)

		conn = 
			get conn, iam_user_phone_number_path(conn, :show, user.id, 
				phone_number.id)

		assert conn.status == 403
	end

	test "create a user phone_number with given identifier, valid params " <>
		"and self permission",
		%{conn: conn, user: user} do
		permission_set = Repo.get_by!(PermissionSet, name: "Self")		
		Factory.insert(:permission_set_grant, user: user, target_user: user,
			permission_set: permission_set)

		conn = 
			post conn, iam_user_phone_number_path(conn, :create, user.id),
			phone_number: %{value: "905111111111"}

		assert conn.status == 201
	end

	test "should be 403 create a user phone_number with other user identifier, " <>
		"valid params and self permission", %{conn: conn, user: user} do
		permission_set = Repo.get_by!(PermissionSet, name: "Self")		
		Factory.insert(:permission_set_grant, user: user, target_user: user,
			permission_set: permission_set)

		user = Factory.insert(:user)

		conn = 
			post conn, iam_user_phone_number_path(conn, :create, user.id),
			phone_number: %{value: "905111111111"}

		assert conn.status == 403
	end

	test "replace a user phone_number with given identifier, valid params " <>
		"and self permission",
		%{conn: conn, user: user} do
		permission_set = Repo.get_by!(PermissionSet, name: "Self")		
		Factory.insert(:permission_set_grant, user: user, target_user: user,
			permission_set: permission_set)

		phone_number = Factory.insert(:user_phone_number, user: user)

		{:ok, "1"} = 
			Rediscl.Query.sadd("#{@redis_keys[:user].phone_number.all}:#{user.id}",
				[Jason.encode!(phone_number)])

		conn = 
			put conn, iam_user_phone_number_path(conn, :update, user.id, 
				phone_number.id),
			phone_number: %{value: "905111111111"}

		assert conn.status == 200
	end

	test "should be 403 error replace a user phone_number with other " <>
		"user identifier, valid params and self permission",
		%{conn: conn, user: user} do
		permission_set = Repo.get_by!(PermissionSet, name: "Self")		
		Factory.insert(:permission_set_grant, user: user, target_user: user,
			permission_set: permission_set)

		user = Factory.insert(:user)
		phone_number = Factory.insert(:user_phone_number, user: user)

		conn = 
			put conn, iam_user_phone_number_path(conn, :update, user.id, phone_number.id),
			phone_number: %{value: "905111111111"}

		assert conn.status == 403
	end

	test "delete a user phone_number with given identifier and self permission",
		%{conn: conn, user: user} do
		permission_set = Repo.get_by!(PermissionSet, name: "Self")		
		Factory.insert(:permission_set_grant, user: user, target_user: user,
			permission_set: permission_set)

		phone_number = Factory.insert(:user_phone_number, user: user)

		{:ok, "1"} = 
			Rediscl.Query.sadd("#{@redis_keys[:user].phone_number.all}:#{user.id}",
				[Jason.encode!(phone_number)])

		{:ok, "OK"} =
			Rediscl.Query.set("#{@redis_keys[:user].phone_number.one}:" <>
				"#{user.id}:#{phone_number.id}", Jason.encode!(phone_number))

		conn = 
			delete conn, iam_user_phone_number_path(conn, :delete, user.id, 
				phone_number.id)

		assert conn.status == 204
	end

	test "should be 403 error delete a user phone_number with other user " <>
		"identifier and self permission",
		%{conn: conn, user: user} do
		permission_set = Repo.get_by!(PermissionSet, name: "Self")		
		Factory.insert(:permission_set_grant, user: user, target_user: user,
			permission_set: permission_set)

		user = Factory.insert(:user)
		phone_number = Factory.insert(:user_phone_number, user: user)

		conn = 
			delete conn, iam_user_phone_number_path(conn, :delete, user.id, 
				phone_number.id)

		assert conn.status == 403
	end	
end