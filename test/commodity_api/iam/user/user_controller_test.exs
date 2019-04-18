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
		users = Factory.insert_list(10, :user)
		
		for x <- 1..10 do 
			user = Enum.at(users, x - 1)
			Factory.insert(:user_state, user: user, source_user: user,
				value: "active")

			if x > 6 do
				Factory.insert(:user_phone_number, user: user,
					value: "90511111111#{x}")
			end
		end

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

		Factory.insert(:user_state, user: user, value: "active")
		Factory.insert(:user_personal_information, user: user,
			given_name: "Abdulkadir", family_name: "DILSIZ")

		conn = get conn, iam_user_path(conn, :show, user.id)

		data = json_response(conn, 200)

		assert data["time_information"]

		data = data["data"]
		
		assert data["id"] == user.id
		assert data["emails"] == []
		assert data["phone_numbers"] == []
		assert data["personal_information"]["given_name"] == "Abdulkadir"
		assert data["personal_information"]["family_name"] == "DILSIZ"
		assert data["inserted_at"] == NaiveDateTime.to_iso8601(user.inserted_at)
	end

	test "show a user with given identifier and state param", %{conn: conn} do
		user = Factory.insert(:user)

		Factory.insert(:user_state, user: user, value: "active")
		Factory.insert(:user_personal_information, user: user,
			given_name: "Abdulkadir", family_name: "DILSIZ")

		conn = get conn, iam_user_path(conn, :show, user.id), state: "active"

		data = json_response(conn, 200)

		assert data["time_information"]

		data = data["data"]
		
		assert data["id"] == user.id
		assert data["emails"] == []
		assert data["phone_numbers"] == []
		assert data["personal_information"]["given_name"] == "Abdulkadir"
		assert data["personal_information"]["family_name"] == "DILSIZ"
		assert data["inserted_at"] == NaiveDateTime.to_iso8601(user.inserted_at)
	end

	test "show a cached state spec user with given identifier", %{conn: conn} do
		user = Factory.insert(:user)

		state = Factory.insert(:user_state, user: user, value: "active")
		{:ok, "OK"} =
			Rediscl.Query.set("#{@redis_keys[:user].state}:#{user.id}",
				Jason.encode!(state))

		Factory.insert(:user_personal_information, user: user,
			given_name: "Abdulkadir", family_name: "DILSIZ")

		conn = get conn, iam_user_path(conn, :show, user.id)

		data = json_response(conn, 200)

		assert data["time_information"]

		data = data["data"]
		
		assert data["id"] == user.id
		assert data["emails"] == []
		assert data["phone_numbers"] == []
		assert data["personal_information"]["given_name"] == "Abdulkadir"
		assert data["personal_information"]["family_name"] == "DILSIZ"
		assert data["inserted_at"] == NaiveDateTime.to_iso8601(user.inserted_at)
	end

	test "show a cached personal information spec user with given identifier", 
		%{conn: conn} do
		user = Factory.insert(:user)

		Factory.insert(:user_state, user: user, value: "active")
		personal_information = 
			Factory.insert(:user_personal_information, user: user,
				given_name: "Abdulkadir", family_name: "DILSIZ")

		{:ok, "OK"} =
			Rediscl.Query.set("#{@redis_keys[:user].personal_information.one}:" <>
				"#{user.id}", Jason.encode!(personal_information))

		conn = get conn, iam_user_path(conn, :show, user.id)

		data = json_response(conn, 200)

		assert data["time_information"]

		data = data["data"]
		
		assert data["id"] == user.id
		assert data["emails"] == []
		assert data["phone_numbers"] == []
		assert data["personal_information"]["given_name"] == "Abdulkadir"
		assert data["personal_information"]["family_name"] == "DILSIZ"
		assert data["inserted_at"] == NaiveDateTime.to_iso8601(user.inserted_at)
	end

	test "show a cached user with given identifier", %{conn: conn} do
		user = Factory.insert(:user)

		{:ok, _} = Rediscl.Query.set("#{@redis_keys[:user].one}:#{user.id}", 
			Jason.encode!(user))

		state = Factory.insert(:user_state, user: user, value: "active")
		{:ok, "OK"} =
			Rediscl.Query.set("#{@redis_keys[:user].state}:#{user.id}",
				Jason.encode!(state))

		conn = get conn, iam_user_path(conn, :show, user.id)

		data = json_response(conn, 200)

		assert data["time_information"]

		data = data["data"]

		assert data["id"] == user.id
		assert data["emails"] == []
		assert data["phone_numbers"] == []
		assert data["inserted_at"] == NaiveDateTime.to_iso8601(user.inserted_at)
	end

	test "show a cached specs user with given identifier", %{conn: conn} do
		user = Factory.insert(:user)

		{:ok, _} = Rediscl.Query.set("#{@redis_keys[:user].one}:#{user.id}", 
			Jason.encode!(user))

		state = Factory.insert(:user_state, user: user, value: "active")
		{:ok, "OK"} =
			Rediscl.Query.set("#{@redis_keys[:user].state}:#{user.id}",
				Jason.encode!(state))

		personal_information = 
			Factory.insert(:user_personal_information, user: user,
				given_name: "Abdulkadir", family_name: "DILSIZ")

		{:ok, "OK"} =
			Rediscl.Query.set("#{@redis_keys[:user].personal_information.one}:" <>
				"#{user.id}", Jason.encode!(personal_information))

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

	test "should be 404 error show a cached user with given identifier " <>
		"if state not cached", 
		%{conn: conn} do
		user = Factory.insert(:user)

		{:ok, _} = Rediscl.Query.set("#{@redis_keys[:user].one}:#{user.id}", 
			Jason.encode!(user))

		state = Factory.insert(:user_state, user: user, value: "passive")
		{:ok, "OK"} =
			Rediscl.Query.set("#{@redis_keys[:user].state}:#{user.id}",
				Jason.encode!(state))

		assert_error_sent 404, fn -> 
			get conn, iam_user_path(conn, :show, user.id)
		end
	end

	test "should be 404 error show a cached user with given identifier " <>
		"user not active", 
		%{conn: conn} do
		user = Factory.insert(:user)

		{:ok, _} = Rediscl.Query.set("#{@redis_keys[:user].one}:#{user.id}", 
			Jason.encode!(user))

		assert_error_sent 404, fn -> 
			get conn, iam_user_path(conn, :show, user.id)
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