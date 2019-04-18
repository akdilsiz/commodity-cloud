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
defmodule Commodity.Api.Iam.User.PhoneNumberControllerTest do
	use Commodity.ConnCase

	alias Commodity.Factory
	alias Commodity.Api.Iam.User.PhoneNumber

	@moduletag login: :user

	setup %{conn: conn, user: user} do
		permission_set = Repo.get_by!(PermissionSet, name: "Superadmin")
		Factory.insert(:permission_set_grant, user: user, target_user: user,
			permission_set: permission_set)

		%{conn: conn, user: user}
	end

	test "options/1", %{conn: conn} do
		conn = options conn, iam_user_phone_number_path(conn, :index, 1)

		assert conn.status == 204
	end

	test "options/2", %{conn: conn} do
		conn = options conn, iam_user_phone_number_path(conn, :show, 1, 2)

		assert conn.status == 204
	end

	test "list all cached user phone_numbers with given identifier", 
		%{conn: conn} do
		user = Factory.insert(:user)

		phone_numbers = 
			for x <- 1..5 do
				Factory.insert(:user_phone_number, user: user, value: "90511111111#{x}")
			end

		{:ok, "5"} =
			Rediscl.Query.sadd("#{@redis_keys[:user].phone_number.all}:#{user.id}",
				Enum.map(phone_numbers, &Jason.encode!(&1)))

		Factory.insert(:user_phone_number_primary, 
			number: Enum.at(phone_numbers, 2), user: user)

		Rediscl.Query.set("#{@redis_keys[:user].phone_number.primary}:#{user.id}",
			Enum.at(phone_numbers, 2).id)

		conn = get conn, iam_user_phone_number_path(conn, :index, user.id)

		data = json_response(conn, 200)

		assert data["time_information"]
		assert data["total_count"] == 5
		assert Enum.count(data["data"]) == 5
		assert Enum.at(Enum.filter(data["data"], &(&1["is_primary"])), 0)["id"] == 
			Enum.at(phone_numbers, 2).id
	end

	test "list all user phone_numbers with given identifier", %{conn: conn} do
		user = Factory.insert(:user)

		phone_numbers = 
			for x <- 1..5 do
				Factory.insert(:user_phone_number, user: user, value: "90511111111#{x}")
			end

		Factory.insert(:user_phone_number_primary, 
			number: Enum.at(phone_numbers, 3), user: user)

		conn = get conn, iam_user_phone_number_path(conn, :index, user.id)

		data = json_response(conn, 200)

		assert data["time_information"]
		assert data["total_count"] == 5
		assert Enum.count(data["data"]) == 5
		assert Enum.at(Enum.filter(data["data"], &(&1["is_primary"])), 0)["id"] == 
			Enum.at(phone_numbers, 3).id

		{:ok, phone_numbers} = 
			Rediscl.Query.smembers("#{@redis_keys[:user].phone_number.all}:" <>
				"#{user.id}")

		assert Enum.count(phone_numbers) == 5
	end

	test "show a cached user phone_number (cached primary) with " <>
		"given identifiers", %{conn: conn} do
		user = Factory.insert(:user)

		phone_number = Factory.insert(:user_phone_number, user: user,
			value: "905111111111")

		{:ok, "OK"} =
			Rediscl.Query.set("#{@redis_keys[:user].phone_number.one}:" <>
				"#{user.id}:#{phone_number.id}", Jason.encode!(phone_number))

		Factory.insert(:user_phone_number_primary, user: user, 
			number: phone_number)

		{:ok, "OK"} =
			Rediscl.Query.set("#{@redis_keys[:user].phone_number.primary}:#{user.id}",
				phone_number.id)

		conn = 
			get conn, iam_user_phone_number_path(conn, :show, user.id, 
				phone_number.id)

		data = json_response(conn, 200)

		assert data["time_information"]

		data = data["data"]

		assert data["id"] == phone_number.id
		assert data["user_id"] == user.id
		assert data["value"] == "905111111111"
		assert data["is_primary"]
		assert data["inserted_at"] == 
			NaiveDateTime.to_iso8601(phone_number.inserted_at)
		assert data["updated_at"] == 
			NaiveDateTime.to_iso8601(phone_number.updated_at)
	end

	test "show a user phone_number with given identifiers", %{conn: conn} do
		user = Factory.insert(:user)

		phone_number = Factory.insert(:user_phone_number, user: user,
			value: "905111111111")

		conn = 
			get conn, iam_user_phone_number_path(conn, :show, user.id, 
				phone_number.id)

		data = json_response(conn, 200)

		assert data["time_information"]

		data = data["data"]

		assert data["id"] == phone_number.id
		assert data["user_id"] == user.id
		assert data["value"] == "905111111111"
		assert data["is_primary"] == false
		assert data["inserted_at"] == 
			NaiveDateTime.to_iso8601(phone_number.inserted_at)
		assert data["updated_at"] == 
			NaiveDateTime.to_iso8601(phone_number.updated_at)
	end

	test "show a user phone_number (primary) with given identifiers", 
		%{conn: conn} do
		user = Factory.insert(:user)

		phone_number = Factory.insert(:user_phone_number, user: user,
			value: "905111111111")

		Factory.insert(:user_phone_number_primary, user: user, 
			number: phone_number)

		conn = 
			get conn, iam_user_phone_number_path(conn, :show, user.id, 
				phone_number.id)

		data = json_response(conn, 200)

		assert data["time_information"]

		data = data["data"]

		assert data["id"] == phone_number.id
		assert data["user_id"] == user.id
		assert data["value"] == "905111111111"
		assert data["is_primary"]
		assert data["inserted_at"] == 
			NaiveDateTime.to_iso8601(phone_number.inserted_at)
		assert data["updated_at"] == 
			NaiveDateTime.to_iso8601(phone_number.updated_at)
	end

	test "should be 404 error show a user phone_number with given identifiers",
		%{conn: conn} do
		user = Factory.insert(:user)

		assert_error_sent 404, fn ->
			get conn, iam_user_phone_number_path(conn, :show, user.id, 999999)
		end		
	end

	test "create a user phone_number with given identifier and valid params",
		%{conn: conn} do
		user = Factory.insert(:user)

		conn = 
			post conn, iam_user_phone_number_path(conn, :create, user.id),
			phone_number: %{value: "905111111111"}

		data = json_response(conn, 201)

		assert data["time_information"]

		data = data["data"]

		assert data["id"]
		assert data["user_id"] == user.id
		assert data["value"] == "905111111111"
		assert data["is_primary"] == false
		assert data["inserted_at"]
		assert data["updated_at"]

		phone_number = Repo.get_by!(PhoneNumber, id: data["id"], user_id: user.id)

		{:ok, "1"} =
			Rediscl.Query.sismember("#{@redis_keys[:user].phone_number.all}:" <>
				"#{user.id}", Jason.encode!(phone_number))

		{:ok, cached_phone_number} = 
			Rediscl.Query.get("#{@redis_keys[:user].phone_number.one}:" <>
				"#{user.id}:#{phone_number.id}")

		cached_phone_number = 
			Jason.decode!(cached_phone_number, [{:keys, :atoms!}])

		assert cached_phone_number.id == data["id"]
		assert cached_phone_number.user_id == user.id
		assert cached_phone_number.value == "905111111111"
		assert cached_phone_number.inserted_at == data["inserted_at"]
		assert cached_phone_number.updated_at == data["updated_at"]
	end

	test "should be 422 error create user phone_number with given identifier " <>
		"and invalid params", %{conn: conn} do
		user = Factory.insert(:user)		

		conn =
			post conn, iam_user_phone_number_path(conn, :create, user.id),
			phone_number: %{value: false}

		assert conn.status == 422
	end

	test "should be 422 error create user phone_number with given " <>
		"identifier and valie params if phone_number has already been taken", 
		%{conn: conn} do
		user = Factory.insert(:user)		

		Factory.insert(:user_phone_number, value: "905111111111")

		conn =
			post conn, iam_user_phone_number_path(conn, :create, user.id),
			phone_number: %{value: "90511"}

		assert conn.status == 422
	end

	test "replace a user phone_number with given identifiers and valid params",
		%{conn: conn} do
		user = Factory.insert(:user)

		phone_number = Factory.insert(:user_phone_number, user: user,
			value: "905111111111")

		{:ok, "1"} = 
			Rediscl.Query.sadd("#{@redis_keys[:user].phone_number.all}:#{user.id}",
				[Jason.encode!(phone_number)])

		{:ok, "OK"} =
			Rediscl.Query.set("#{@redis_keys[:user].phone_number.one}:#{user.id}:" <>
				"#{phone_number.id}", Jason.encode!(phone_number))

		Factory.insert(:user_phone_number_primary, user: user, 
			number: phone_number)

		{:ok, "OK"} =
			Rediscl.Query.set("#{@redis_keys[:user].phone_number.primary}:#{user.id}",
				phone_number.id)

		conn = 
			put conn, iam_user_phone_number_path(conn, :update, user.id, 
				phone_number.id),
			phone_number: %{value: "905111111112"}

		data = json_response(conn, 200)

		assert data["time_information"]

		data = data["data"]

		assert data["id"] == phone_number.id
		assert data["user_id"] == user.id
		assert data["value"] == "905111111112"
		refute data["value"] == "905111111111"
		assert data["inserted_at"] == 
			NaiveDateTime.to_iso8601(phone_number.inserted_at)
		refute data["updated_at"] == 
			NaiveDateTime.to_iso8601(phone_number.updated_at)
		assert data["updated_at"]

		assert {:ok, "0"} =
			Rediscl.Query.sismember("#{@redis_keys[:user].phone_number.all}:" <>
				"#{user.id}", Jason.encode!(phone_number))

		assert {:ok, cached_phone_number} = 
			Rediscl.Query.get("#{@redis_keys[:user].phone_number.one}:" <>
				"#{user.id}:#{phone_number.id}")

		cached_phone_number = 
			Jason.decode!(cached_phone_number, [{:keys, :atoms!}])

		assert cached_phone_number.value == "905111111112"
		assert cached_phone_number.updated_at == data["updated_at"]

		phone_number = Repo.get_by!(PhoneNumber, id: phone_number.id, 
			user_id: user.id)

		assert {:ok, "1"} =
			Rediscl.Query.sismember("#{@redis_keys[:user].phone_number.all}:" <>
				"#{user.id}", Jason.encode!(phone_number))
	end

	test "should be 404 error replace a user phone_number with given " <>
		"identifiers and valid params", %{conn: conn} do
		user = Factory.insert(:user)	

		assert_error_sent 404, fn -> 
			put conn, iam_user_phone_number_path(conn, :update, user.id, 999999),
			phone_number: %{value: "905111111111"}
		end
	end

	test "should be 422 error replace a user phone_number with given " <>
		"identifiers and invalid params", %{conn: conn} do
		user = Factory.insert(:user)	
		phone_number = Factory.insert(:user_phone_number, user: user)
		
		conn =
			put conn, iam_user_phone_number_path(conn, :update, user.id, 
				phone_number.id),
			phone_number: %{value: "ups"}

		assert conn.status == 422
	end

	test "delete a user phone_number with given identifiers", %{conn: conn} do
		user = Factory.insert(:user)
		phone_number = Factory.insert(:user_phone_number, user: user,
			value: "905111111111")

		{:ok, "1"} = 
			Rediscl.Query.sadd("#{@redis_keys[:user].phone_number.all}:#{user.id}",
				[Jason.encode!(phone_number)])

		{:ok, "OK"} =
			Rediscl.Query.set("#{@redis_keys[:user].phone_number.one}:" <>
				"#{user.id}:#{phone_number.id}", Jason.encode!(phone_number))

		{:ok, "OK"} =
			Rediscl.Query.set("#{@redis_keys[:user].phone_number.primary}:#{user.id}",
				phone_number.id)

		conn = delete conn, iam_user_phone_number_path(conn, :delete, user.id, 
			phone_number.id)

		assert conn.status == 204

		user = Factory.insert(:user)

		phone_number = Factory.insert(:user_phone_number, user: user,
			value: "905111111111")

		assert {:ok, "0"} = 
			Rediscl.Query.sismember("#{@redis_keys[:user].phone_number.all}:" <>
				"#{user.id}", Jason.encode!(phone_number))

		assert {:error, :undefined} =
			Rediscl.Query.get("#{@redis_keys[:user].phone_number.one}:" <>
				"#{user.id}:#{phone_number.id}")
	end

	test "should be 400 error delete a user phone_number with given identifiers " <>
		"if phone_number is primary", %{conn: conn} do
		user = Factory.insert(:user)
		phone_number = Factory.insert(:user_phone_number, user: user,
			value: "905111111111")

		Factory.insert(:user_phone_number_primary, user: user, 
			number: phone_number)

		assert_error_sent 400, fn -> 
			delete conn, iam_user_phone_number_path(conn, :delete, user.id, 
				phone_number.id)
		end
	end
end