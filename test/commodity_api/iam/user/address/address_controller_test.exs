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
defmodule Commodity.Api.Iam.User.AddressControllerTest do
	use Commodity.ConnCase

	alias Commodity.Factory
	alias Commodity.Api.Iam.User.Address

	@moduletag login: :user

	setup %{conn: conn, user: user} do
		permission_set = Repo.get_by!(PermissionSet, name: "Superadmin")
		Factory.insert(:permission_set_grant, user: user, target_user: user,
			permission_set: permission_set)

		%{conn: conn, user: user}
	end

	test "options/1", %{conn: conn} do
		conn = options conn, iam_user_address_path(conn, :index, 1)

		assert conn.status == 204
	end

	test "list all cached user addresses with given identifier", %{conn: conn} do
		user = Factory.insert(:user)
		addresses = Factory.insert_list(20, :user_address, user: user)

		Rediscl.Query.sadd("#{@redis_keys[:user].address.all}:#{user.id}",
			Enum.map(addresses, &Jason.encode!(&1)))

		conn = get conn, iam_user_address_path(conn, :index, user.id)

		data = json_response(conn, 200)

		assert data["time_information"]
		assert data["total_count"] == 20
		assert Enum.count(data["data"]) == 20
	end

	test "list all user addresses with given identifier", %{conn: conn} do
		user = Factory.insert(:user)
		Factory.insert_list(25, :user_address, user: user)

		conn = get conn, iam_user_address_path(conn, :index, user.id)

		data = json_response(conn, 200)

		assert data["time_information"]
		assert data["total_count"] == 25
		assert Enum.count(data["data"]) == 25
	end

	test "show a cached user address with given identifiers", %{conn: conn} do
		user = Factory.insert(:user)
		address = Factory.insert(:user_address, user: user,
			type: "home",
			name: "Home 1",
			country: "Turkey",
			city: "Istanbul",
			state: "Atasehir",
			zip_code: "34212",
			address: "Address")

		{:ok, "OK"} = 
			Rediscl.Query.set("#{@redis_keys[:user].address.one}:#{user.id}:" <>
				"#{address.id}", Jason.encode!(address))

		conn = get conn, iam_user_address_path(conn, :show, user.id, address.id)

		data = json_response(conn, 200)

		assert data["time_information"]

		data = data["data"]

		assert data["id"] == address.id
		assert data["user_id"] == user.id
		assert data["type"] == "home"
		assert data["name"] == "Home 1"
		assert data["country"] == "Turkey"
		assert data["city"] == "Istanbul"
		assert data["state"] == "Atasehir"
		assert data["zip_code"] == "34212"
		assert data["address"] == "Address"
		assert data["inserted_at"] == NaiveDateTime.to_iso8601(address.inserted_at)
		assert data["updated_at"] == NaiveDateTime.to_iso8601(address.updated_at)
	end

	test "show a user address with given identifiers", %{conn: conn} do
		user = Factory.insert(:user)
		address = Factory.insert(:user_address, user: user,
			type: "home",
			name: "Home 1",
			country: "Turkey",
			city: "Istanbul",
			state: "Atasehir",
			zip_code: "34212",
			address: "Address")

		conn = get conn, iam_user_address_path(conn, :show, user.id, address.id)

		data = json_response(conn, 200)

		assert data["time_information"]

		data = data["data"]

		assert data["id"] == address.id
		assert data["user_id"] == user.id
		assert data["type"] == "home"
		assert data["name"] == "Home 1"
		assert data["country"] == "Turkey"
		assert data["city"] == "Istanbul"
		assert data["state"] == "Atasehir"
		assert data["zip_code"] == "34212"
		assert data["address"] == "Address"
		assert data["inserted_at"] == NaiveDateTime.to_iso8601(address.inserted_at)
		assert data["updated_at"] == NaiveDateTime.to_iso8601(address.updated_at)

		assert {:ok, cached_address} =
			Rediscl.Query.get("#{@redis_keys[:user].address.one}:#{user.id}:" <>
				"#{address.id}")

		cached_address = Jason.decode!(cached_address, [{:keys, :atoms!}])

		assert cached_address.id == address.id
		assert cached_address.user_id == user.id
		assert cached_address.type == "home"
		assert cached_address.name == "Home 1"
		assert cached_address.country == "Turkey"
		assert cached_address.city == "Istanbul"
		assert cached_address.state == "Atasehir"
		assert cached_address.zip_code == "34212"
		assert cached_address.address == "Address"
		assert cached_address.inserted_at == NaiveDateTime.to_iso8601(address.inserted_at)
		assert cached_address.updated_at == NaiveDateTime.to_iso8601(address.updated_at)
	end

	test "should be 404 error show a user address with given identifiers if " <>
		"address not exists", %{conn: conn} do
		user = Factory.insert(:user)		

		assert_error_sent 404, fn -> 
			get conn, iam_user_address_path(conn, :show, user.id, 99_999_999)
		end
	end

	test "create a user address with given identifier and valid params",
		%{conn: conn} do
		user = Factory.insert(:user)		

		conn =
			post conn, iam_user_address_path(conn, :create, user.id),
			address: %{type: "work", name: "Work 1", country: "Turkey",
				city: "Rize", state: "Merkez", zip_code: "53100", 
				address: "Rize Merkez"}

		data = json_response(conn, 201)

		assert data["time_information"]

		data = data["data"]

		assert data["id"]
		assert data["user_id"] == user.id
		assert data["type"] == "work"
		assert data["name"] == "Work 1"
		assert data["country"] == "Turkey"
		assert data["city"] == "Rize"
		assert data["state"] == "Merkez"
		assert data["zip_code"] == "53100"
		assert data["address"] == "Rize Merkez"
		assert data["inserted_at"]
		assert data["updated_at"]

		address = Repo.get_by!(Address, id: data["id"], user_id: user.id)

		assert {:ok, "1"} =
			Rediscl.Query.sismember("#{@redis_keys[:user].address.all}:#{user.id}",
				Jason.encode!(address))

		assert {:ok, cached_address} =
			Rediscl.Query.get("#{@redis_keys[:user].address.one}:#{user.id}:" <>
				"#{address.id}")

		cached_address = Jason.decode!(cached_address, [{:keys, :atoms!}])

		assert cached_address.id == address.id
		assert cached_address.user_id == user.id
		assert cached_address.type == "work"
		assert cached_address.name == "Work 1"
		assert cached_address.country == "Turkey"
		assert cached_address.city == "Rize"
		assert cached_address.state == "Merkez"
		assert cached_address.zip_code == "53100"
		assert cached_address.address == "Rize Merkez"
		assert cached_address.inserted_at == data["inserted_at"]
		assert cached_address.updated_at == data["updated_at"]
	end

	test "should be 422 error create a user address with given identifier and " <>
		"invalid params", %{conn: conn} do
		user = Factory.insert(:user)		

		conn =
			post conn, iam_user_address_path(conn, :create, user.id),
			address: %{type: "upss", name: false}

		assert conn.status == 422
	end

	test "replace a user address with given identifiers and valid params",
		%{conn: conn} do
		user = Factory.insert(:user)		
		address = Factory.insert(:user_address, user: user,
			type: "work", name: "Work 1", country: "Turkey",
			city: "Rize", state: "Merkez", zip_code: "53100", 
			address: "Rize Merkez")

		{:ok, "1"} =
				Rediscl.Query.sadd("#{@redis_keys[:user].address.all}:#{user.id}",
					[Jason.encode!(address)])

		{:ok, "OK"} =
				Rediscl.Query.set("#{@redis_keys[:user].address.one}:#{user.id}:" <>
					"#{address.id}", Jason.encode!(address))

		conn =
			put conn, iam_user_address_path(conn, :update, user.id, address.id),
			address: %{name: "Work 1 / Edit"}

		data = json_response(conn, 200)

		assert data["time_information"]

		data = data["data"]

		assert data["id"] == address.id
		assert data["user_id"] == user.id
		assert data["type"] == "work"
		refute data["name"] == "Work 1"
		assert data["name"] == "Work 1 / edit" # see Address.to_capitalize
		assert data["country"] == "Turkey"
		assert data["city"] == "Rize"
		assert data["state"] == "Merkez"
		assert data["zip_code"] == "53100"
		assert data["address"] == "Rize Merkez"
		assert data["inserted_at"] == NaiveDateTime.to_iso8601(address.inserted_at)
		refute data["updated_at"] == NaiveDateTime.to_iso8601(address.updated_at)
		assert data["updated_at"]

		assert {:ok, "0"} =
			Rediscl.Query.sismember("#{@redis_keys[:user].address.all}:#{user.id}",
				Jason.encode!(address))

		address = Repo.get_by!(Address, id: data["id"], user_id: user.id)

		assert {:ok, "1"} =
			Rediscl.Query.sismember("#{@redis_keys[:user].address.all}:#{user.id}",
				Jason.encode!(address))

		assert {:ok, cached_address} =
			Rediscl.Query.get("#{@redis_keys[:user].address.one}:#{user.id}:" <>
				"#{address.id}")

		cached_address = Jason.decode!(cached_address, [{:keys, :atoms!}])

		assert cached_address.id == address.id
		assert cached_address.user_id == user.id
		assert cached_address.type == "work"
		assert cached_address.name == "Work 1 / edit" # see Address.to_capitalize
		assert cached_address.country == "Turkey"
		assert cached_address.city == "Rize"
		assert cached_address.state == "Merkez"
		assert cached_address.zip_code == "53100"
		assert cached_address.address == "Rize Merkez"
		assert cached_address.inserted_at == data["inserted_at"]
		assert cached_address.updated_at == data["updated_at"]
	end

	test "should be 422 error replace a user address with given identifiers " <>
		"and invalid params", %{conn: conn} do
		user = Factory.insert(:user)		
		address = Factory.insert(:user_address, user: user,
			type: "work", name: "Work 1", country: "Turkey",
			city: "Rize", state: "Merkez", zip_code: "53100", 
			address: "Rize Merkez")

		{:ok, "1"} =
				Rediscl.Query.sadd("#{@redis_keys[:user].address.all}:#{user.id}",
					[Jason.encode!(address)])

		{:ok, "OK"} =
				Rediscl.Query.set("#{@redis_keys[:user].address.one}:#{user.id}:" <>
					"#{address.id}", Jason.encode!(address))

		conn =
			put conn, iam_user_address_path(conn, :update, user.id, address.id),
			address: %{type: "unknown"}

		assert conn.status == 422
	end

	test "should be 404 error replace a user address with given identifiers " <> 
		"and valid params if address not exists", %{conn: conn} do
		user = Factory.insert(:user)		

		assert_error_sent 404, fn -> 
			put conn, iam_user_address_path(conn, :update, user.id, 99_999_999),
			address: %{type: "home", state: "Rize"}
		end
	end
end