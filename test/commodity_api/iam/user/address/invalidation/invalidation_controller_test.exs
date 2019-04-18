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
defmodule Commodity.Api.Iam.User.Address.InvalidationControllerTest do
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
		conn = 
			options conn, iam_user_address_invalidation_path(conn, :create, 1, 1)

		assert conn.status == 204
	end

	test "create a user address invalidation with given identifiers",
		%{conn: conn} do
		user = Factory.insert(:user)
		address = Factory.insert(:user_address, user: user)

		{:ok, "1"} =
				Rediscl.Query.sadd("#{@redis_keys[:user].address.all}:#{user.id}",
					[Jason.encode!(address)])

		{:ok, "OK"} =
				Rediscl.Query.set("#{@redis_keys[:user].address.one}:#{user.id}:" <>
					"#{address.id}", Jason.encode!(address))

		conn =
			post conn, 
				iam_user_address_invalidation_path(conn, :create, user.id, address.id)

		assert conn.status == 201
	end

	test "should be 404 error create a user address invalidation with given " <>
		"identifiers if address not exists", %{conn: conn} do
		user = Factory.insert(:user)		

		assert_error_sent 404, fn -> 
			post conn, 
				iam_user_address_invalidation_path(conn, :create, user.id, 99_999_999)
		end
	end

	test "should be 422 error create a user address invalidation with given 
		identifiers if address already invalidate", %{conn: conn} do
		user = Factory.insert(:user)
		address = Factory.insert(:user_address, user: user)

		{:ok, "1"} =
				Rediscl.Query.sadd("#{@redis_keys[:user].address.all}:#{user.id}",
					[Jason.encode!(address)])

		{:ok, "OK"} =
				Rediscl.Query.set("#{@redis_keys[:user].address.one}:#{user.id}:" <>
					"#{address.id}", Jason.encode!(address))

		Factory.insert(:user_address_invalidation, address: address)

		conn =
			post conn, 
				iam_user_address_invalidation_path(conn, :create, user.id, address.id)

		assert conn.status == 422

		data = json_response(conn, 422)

		assert data["errors"]["changeset"]["address_id"] ==
			["has already been taken"]
	end
end