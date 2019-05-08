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
defmodule Commodity.Api.BrandControllerTest do
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
		conn = options conn, brand_path(conn, :options)

		assert conn.status == 204
	end

	test "options/1", %{conn: conn} do
		conn = options conn, brand_path(conn, :show, 1)

		assert conn.status == 204
	end

	test "list all brands", %{conn: conn} do
		for _ <- 1..10 do
			Factory.insert(:brand)
		end

		conn = get conn, brand_path(conn, :index)

		data = json_response(conn, 200)

		assert data["time_information"]
		assert data["total_count"] == 10
		assert Enum.count(data["data"]) == 10
	end

	test "list all brands with liimit and offset params", %{conn: conn} do
		for _ <- 1..30 do
			Factory.insert(:brand)
		end

		conn = get conn, brand_path(conn, :index), limit: 10, offset: 20

		data = json_response(conn, 200)

		assert data["time_information"]
		assert data["total_count"] == 30
		assert Enum.count(data["data"]) == 10
	end

	test "show a brand with given identifier", %{conn: conn} do
		brand = Factory.insert(:brand)

		conn = get conn, brand_path(conn, :show, brand.id)

		data = json_response(conn, 200)

		assert data["time_information"]

		data = data["data"]

		assert data["id"] == brand.id
		assert data["inserted_at"] == NaiveDateTime.to_iso8601(brand.inserted_at)
	
		assert {:ok, _} =
			Rediscl.Query.get("#{@redis_keys[:brand].one}:#{brand.id}")
	end

	test "show a cached brand with given identifier", %{conn: conn} do
		brand = Factory.insert(:brand)

		{:ok, "OK"} =
			Rediscl.Query.set("#{@redis_keys[:brand].one}:#{brand.id}",
				Jason.encode!(brand))

		conn = get conn, brand_path(conn, :show, brand.id)

		data = json_response(conn, 200)

		assert data["time_information"]

		data = data["data"]

		assert data["id"] == brand.id
		assert data["inserted_at"] == NaiveDateTime.to_iso8601(brand.inserted_at)
	end

	test "should be 404 error show a brand with given identifier if brand not" <>
		" exists", %{conn: conn} do
		assert_error_sent 404, fn -> 
			get conn, brand_path(conn, :show, 1234)
		end		
	end

	test "creaet a brand with valid params", %{conn: conn} do
		conn = post conn, brand_path(conn, :create), brand: %{}

		data = json_response(conn, 201)

		assert data["time_information"]

		data = data["data"]

		assert data["id"]
		assert data["inserted_at"]

		assert {:ok, cached_brand} = 
			Rediscl.Query.get("#{@redis_keys[:brand].one}:" <> to_string(data["id"]))

		cached_brand = Jason.decode!(cached_brand, [{:keys, :atoms!}])

		assert cached_brand.id == data["id"]
		assert cached_brand.inserted_at == data["inserted_at"]
	end

	test "delete a brand with given identifier", %{conn: conn} do
		brand = Factory.insert(:brand)

		{:ok, "OK"} =
			Rediscl.Query.set("#{@redis_keys[:brand].one}:#{brand.id}",
				Jason.encode!(brand))

		conn = delete conn, brand_path(conn, :delete, brand.id)

		assert conn.status == 204

		assert {:error, :undefined} ==
			Rediscl.Query.get("#{@redis_keys[:brand].one}:#{brand.id}")
	end

	test "should be 404 error delete a brand with given identifier if " <>
		"brand not exist", %{conn: conn} do
		assert_error_sent 404, fn -> 
			delete conn, brand_path(conn, :delete, 99_999_999)
		end		
	end
end