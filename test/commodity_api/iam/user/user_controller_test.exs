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

	test "list all users with limit and offset params", %{conn: conn} do
		users = 
			Factory.insert_list(50, :user)
			|> Enum.map(fn x -> 
				Factory.insert(:user_state, user: x, source_user: x,
					value: "active")

				x
			end)

		conn = get conn, iam_user_path(conn, :index), limit: 10, offset: 10

		data = json_response(conn, 200)

		assert data["total_count"] >= 50
		assert data["time_information"]
		assert Enum.count(data["data"]) == 10
		assert List.first(data["data"])["id"] == Enum.at(users, 39).id
	end

	test "list all users with order_by param", %{conn: conn} do
		users = 
			Factory.insert_list(50, :user)
			|> Enum.map(fn x -> 
				Factory.insert(:user_state, user: x, source_user: x,
					value: "active")

				x
			end)

		conn = get conn, iam_user_path(conn, :index), order_by: "asc"

		data = json_response(conn, 200)

		assert data["total_count"] >= 50
		assert data["time_information"]
		assert Enum.count(data["data"]) == 40
		assert List.first(data["data"])["id"] == List.first(users).id
	end
	
	test "show a user with given identifier", %{conn: conn} do
		user = Factory.insert(:user)

		conn = get conn, iam_user_path(conn, :show, user.id)

		data = json_response(conn, 200)

		assert data["time_information"]

		data = data["data"]

		assert data["id"] == user.id
		assert data["emails"] == []
		assert data["phone_numbers"] == []
		assert data["inserted_at"] == NaiveDateTime.to_iso8601(user.inserted_at)
	end

	test "show a cached user with given identifier", %{conn: conn} do
		user = Factory.insert(:user)

		{:ok, _} = Rediscl.Query.set("#{@redis_keys[:user].one}:#{user.id}", 
			Jason.encode!(user))

		conn = get conn, iam_user_path(conn, :show, user.id)

		data = json_response(conn, 200)

		assert data["time_information"]

		data = data["data"]

		assert data["id"] == user.id
		assert data["emails"] == []
		assert data["phone_numbers"] == []
		assert data["inserted_at"] == NaiveDateTime.to_iso8601(user.inserted_at)
	end

	test "should be 404 error show a user with given identifier", %{conn: conn} do
		assert_error_sent 404, fn -> 
			get conn, iam_user_path(conn, :show, 99999999)
		end
	end

	test "create a user with valid params", %{conn: conn} do
		conn = post conn, iam_user_path(conn, :create), user: %{}

		data = json_response(conn, 201)

		assert data["time_information"]

		data = data["data"]

		assert data["id"]
		assert data["phone_numbers"] == []
		assert data["emails"] == []
		assert data["inserted_at"]

		assert {:ok, cached_user} =
			Rediscl.Query.get("#{@redis_keys[:user].one}:" <> 
				Integer.to_string(data["id"]))

		cached_user = Jason.decode!(cached_user, [{:keys, :atoms!}])

		assert cached_user.id == data["id"]
		assert cached_user.inserted_at == data["inserted_at"]
	end

	test "delete a user with given identifier", %{conn: conn} do
		user = Factory.insert(:user)

		{:ok, _} = Rediscl.Query.set("#{@redis_keys[:user].one}:#{user.id}", 
			Jason.encode!(user))
		{:ok, _} = Elastic.put("/user/_doc/#{user.id}", user)

		conn = delete conn, iam_user_path(conn, :delete, user.id)

		assert conn.status == 204

		assert {:error, :undefined} == 
			Rediscl.Query.get("#{@redis_keys[:user].one}:#{user.id}")
	end
end