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
defmodule Commodity.Api.Iam.User.EmailControllerTest do
	use Commodity.ConnCase

	alias Commodity.Factory
	alias Commodity.Api.Iam.User.Email

	@moduletag login: :user

	setup %{conn: conn, user: user} do
		permission_set = Repo.get_by!(PermissionSet, name: "Superadmin")
		Factory.insert(:permission_set_grant, user: user, target_user: user,
			permission_set: permission_set)

		%{conn: conn, user: user}
	end

	test "options/1", %{conn: conn} do
		conn = options conn, iam_user_email_path(conn, :index, 1)

		assert conn.status == 204
	end

	test "options/2", %{conn: conn} do
		conn = options conn, iam_user_email_path(conn, :show, 1, 2)

		assert conn.status == 204
	end

	test "list all cached user emails with given identifier", %{conn: conn} do
		user = Factory.insert(:user)

		emails = Factory.insert_list(5, :user_email, user: user)

		{:ok, "5"} =
			Rediscl.Query.sadd("#{@redis_keys[:user].email.all}:#{user.id}",
				Enum.map(emails, &Jason.encode!(&1)))

		Factory.insert(:user_email_primary, email: Enum.at(emails, 2), user: user)

		Rediscl.Query.set("#{@redis_keys[:user].email.primary}:#{user.id}",
			Enum.at(emails, 2).id)

		conn = get conn, iam_user_email_path(conn, :index, user.id)

		data = json_response(conn, 200)

		assert data["time_information"]
		assert data["total_count"] == 5
		assert Enum.count(data["data"]) == 5
		assert Enum.at(Enum.filter(data["data"], &(&1["is_primary"])), 0)["id"] == 
			Enum.at(emails, 2).id
	end

	test "list all user emails with given identifier", %{conn: conn} do
		user = Factory.insert(:user)

		emails = Factory.insert_list(6, :user_email, user: user)

		Factory.insert(:user_email_primary, email: Enum.at(emails, 3), user: user)

		conn = get conn, iam_user_email_path(conn, :index, user.id)

		data = json_response(conn, 200)

		assert data["time_information"]
		assert data["total_count"] == 6
		assert Enum.count(data["data"]) == 6
		assert Enum.at(Enum.filter(data["data"], &(&1["is_primary"])), 0)["id"] == 
			Enum.at(emails, 3).id

		{:ok, emails} = 
			Rediscl.Query.smembers("#{@redis_keys[:user].email.all}:#{user.id}")

		assert Enum.count(emails) == 6
	end

	test "show a cached user email (cached primary) with given identifiers", 
		%{conn: conn} do
		user = Factory.insert(:user)

		email = Factory.insert(:user_email, user: user,
			value: "email@email.com")

		{:ok, "OK"} =
			Rediscl.Query.set("#{@redis_keys[:user].email.one}:#{user.id}:#{email.id}",
				Jason.encode!(email))

		Factory.insert(:user_email_primary, user: user, email: email)

		{:ok, "OK"} =
			Rediscl.Query.set("#{@redis_keys[:user].email.primary}:#{user.id}",
				email.id)

		conn = get conn, iam_user_email_path(conn, :show, user.id, email.id)

		data = json_response(conn, 200)

		assert data["time_information"]

		data = data["data"]

		assert data["id"] == email.id
		assert data["user_id"] == user.id
		assert data["value"] == "email@email.com"
		assert data["is_primary"]
		assert data["inserted_at"] == NaiveDateTime.to_iso8601(email.inserted_at)
		assert data["updated_at"] == NaiveDateTime.to_iso8601(email.updated_at)
	end

	test "show a user email with given identifiers", %{conn: conn} do
		user = Factory.insert(:user)

		email = Factory.insert(:user_email, user: user,
			value: "email@email.com")


		conn = get conn, iam_user_email_path(conn, :show, user.id, email.id)

		data = json_response(conn, 200)

		assert data["time_information"]

		data = data["data"]

		assert data["id"] == email.id
		assert data["user_id"] == user.id
		assert data["value"] == "email@email.com"
		assert data["is_primary"] == false
		assert data["inserted_at"] == NaiveDateTime.to_iso8601(email.inserted_at)
		assert data["updated_at"] == NaiveDateTime.to_iso8601(email.updated_at)
	end

	test "show a user email (primary) with given identifiers", %{conn: conn} do
		user = Factory.insert(:user)

		email = Factory.insert(:user_email, user: user,
			value: "email@email.com")

		Factory.insert(:user_email_primary, user: user, email: email)

		conn = get conn, iam_user_email_path(conn, :show, user.id, email.id)

		data = json_response(conn, 200)

		assert data["time_information"]

		data = data["data"]

		assert data["id"] == email.id
		assert data["user_id"] == user.id
		assert data["value"] == "email@email.com"
		assert data["is_primary"]
		assert data["inserted_at"] == NaiveDateTime.to_iso8601(email.inserted_at)
		assert data["updated_at"] == NaiveDateTime.to_iso8601(email.updated_at)
	end

	test "should be 404 error show a user email with given identifiers",
		%{conn: conn} do
		user = Factory.insert(:user)

		assert_error_sent 404, fn ->
			get conn, iam_user_email_path(conn, :show, user.id, 999999)
		end		
	end

	test "create a user email with given identifier and valid params",
		%{conn: conn} do
		user = Factory.insert(:user)

		conn = 
			post conn, iam_user_email_path(conn, :create, user.id),
			email: %{value: "email@email.com"}

		data = json_response(conn, 201)

		assert data["time_information"]

		data = data["data"]

		assert data["id"]
		assert data["user_id"] == user.id
		assert data["value"] == "email@email.com"
		assert data["is_primary"] == false
		assert data["inserted_at"]
		assert data["updated_at"]

		email = Repo.get_by!(Email, id: data["id"], user_id: user.id)

		{:ok, "1"} =
			Rediscl.Query.sismember("#{@redis_keys[:user].email.all}:#{user.id}",
				Jason.encode!(email))

		{:ok, cached_email} = 
			Rediscl.Query.get("#{@redis_keys[:user].email.one}:#{user.id}:#{email.id}")

		cached_email = Jason.decode!(cached_email, [{:keys, :atoms!}])

		assert cached_email.id == data["id"]
		assert cached_email.user_id == user.id
		assert cached_email.value == "email@email.com"
		assert cached_email.inserted_at == data["inserted_at"]
		assert cached_email.updated_at == data["updated_at"]
	end

	test "should be 422 error create user email with given identifier and " <>
		"invalid params", %{conn: conn} do
		user = Factory.insert(:user)		

		conn =
			post conn, iam_user_email_path(conn, :create, user.id),
			email: %{value: "email"}

		assert conn.status == 422
	end

	test "should be 422 error create user email with given identifier and " <>
		"valie params if email has already been taken", %{conn: conn} do
		user = Factory.insert(:user)		

		Factory.insert(:user_email, value: "email@email.com")

		conn =
			post conn, iam_user_email_path(conn, :create, user.id),
			email: %{value: "email@email.com"}

		assert conn.status == 422
	end

	test "replace a user email with given identifiers and valid params",
		%{conn: conn} do
		user = Factory.insert(:user)

		email = Factory.insert(:user_email, user: user,
			value: "email@email.com")

		{:ok, "1"} = 
			Rediscl.Query.sadd("#{@redis_keys[:user].email.all}:#{user.id}",
				[Jason.encode!(email)])

		{:ok, "OK"} =
			Rediscl.Query.set("#{@redis_keys[:user].email.one}:#{user.id}:#{email.id}",
				Jason.encode!(email))

		Factory.insert(:user_email_primary, user: user, email: email)

		{:ok, "OK"} =
			Rediscl.Query.set("#{@redis_keys[:user].email.primary}:#{user.id}",
				email.id)

		conn = 
			put conn, iam_user_email_path(conn, :update, user.id, email.id),
			email: %{value: "email2@email.com"}

		data = json_response(conn, 200)

		assert data["time_information"]

		data = data["data"]

		assert data["id"] == email.id
		assert data["user_id"] == user.id
		assert data["value"] == "email2@email.com"
		refute data["value"] == "email@email.com"
		assert data["inserted_at"] == NaiveDateTime.to_iso8601(email.inserted_at)
		refute data["updated_at"] == NaiveDateTime.to_iso8601(email.updated_at)
		assert data["updated_at"]

		assert {:ok, "0"} =
			Rediscl.Query.sismember("#{@redis_keys[:user].email.all}:#{user.id}",
				Jason.encode!(email))

		assert {:ok, cached_email} = 
			Rediscl.Query.get("#{@redis_keys[:user].email.one}:#{user.id}:#{email.id}")

		cached_email = Jason.decode!(cached_email, [{:keys, :atoms!}])

		assert cached_email.value == "email2@email.com"
		assert cached_email.updated_at == data["updated_at"]

		email = Repo.get_by!(Email, id: email.id, user_id: user.id)

		assert {:ok, "1"} =
			Rediscl.Query.sismember("#{@redis_keys[:user].email.all}:#{user.id}",
				Jason.encode!(email))
	end

	test "should be 404 error replace a user email with given identifiers and " <>
		"valid params", %{conn: conn} do
		user = Factory.insert(:user)	

		assert_error_sent 404, fn -> 
			put conn, iam_user_email_path(conn, :update, user.id, 999999),
			email: %{value: "email@email.com"}
		end
	end

	test "should be 422 error replace a user email with given identifiers and " <>
		"invalid params", %{conn: conn} do
		user = Factory.insert(:user)	
		email = Factory.insert(:user_email, user: user)
		
		conn =
			put conn, iam_user_email_path(conn, :update, user.id, email.id),
			email: %{value: "email"}

		assert conn.status == 422
	end

	test "delete a user email with given identifiers", %{conn: conn} do
		user = Factory.insert(:user)
		email = Factory.insert(:user_email, user: user,
			value: "email@email.com")

		{:ok, "1"} = 
			Rediscl.Query.sadd("#{@redis_keys[:user].email.all}:#{user.id}",
				[Jason.encode!(email)])

		{:ok, "OK"} =
			Rediscl.Query.set("#{@redis_keys[:user].email.one}:#{user.id}:#{email.id}",
				Jason.encode!(email))

		{:ok, "OK"} =
			Rediscl.Query.set("#{@redis_keys[:user].email.primary}:#{user.id}",
				email.id)

		conn = delete conn, iam_user_email_path(conn, :delete, user.id, email.id)

		assert conn.status == 204

				user = Factory.insert(:user)

		email = Factory.insert(:user_email, user: user,
			value: "email@email.com")

		assert {:ok, "0"} = 
			Rediscl.Query.sismember("#{@redis_keys[:user].email.all}:#{user.id}",
				Jason.encode!(email))

		assert {:error, :undefined} =
			Rediscl.Query.get("#{@redis_keys[:user].email.one}:#{user.id}:#{email.id}")
	end

	test "should be 400 error delete a user email with given identifiers " <>
		"if email is primary", %{conn: conn} do
		user = Factory.insert(:user)
		email = Factory.insert(:user_email, user: user,
			value: "email@email.com")

		Factory.insert(:user_email_primary, user: user, email: email)

		assert_error_sent 400, fn -> 
			delete conn, iam_user_email_path(conn, :delete, user.id, email.id)
		end
	end
end