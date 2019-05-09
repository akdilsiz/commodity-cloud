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
defmodule Commodity.Api.Brand.DetailControllerTest do
	use Commodity.ConnCase

	alias Commodity.Factory

	@moduletag login: :user

	setup %{conn: conn, user: user} do
		permission_set = Repo.get_by!(PermissionSet, name: "Superadmin")
		Factory.insert(:permission_set_grant, user: user, target_user: user,
			permission_set: permission_set)

		%{conn: conn, user: user}
	end

	test "create a brand detail with given identifier and valid params",
		%{conn: conn} do
		brand = Factory.insert(:brand)

		conn = 
			post conn, brand_detail_path(conn, :create, brand.id),
			detail: %{name: "Detail", slug: "detail-one"}

		data = json_response(conn, 201)

		assert data["time_information"]

		data = data["data"]

		assert data["id"]
		assert data["brand_id"] == brand.id
		assert data["name"] == "Detail"
		assert data["slug"] == "detail-one"
		assert data["inserted_at"]

		assert {:ok, cached_detail} =
			Rediscl.Query.get("#{@redis_keys[:brand].detail}:#{brand.id}")

		cached_detail = Jason.decode!(cached_detail, [{:keys, :atoms!}])

		assert cached_detail.id == data["id"]
		assert cached_detail.brand_id == brand.id
		assert cached_detail.name == "Detail"
		assert cached_detail.slug == "detail-one"
		assert cached_detail.inserted_at == data["inserted_at"]		
	end

	test "should be 422 error create a brand detail with given identifier" <>
		" and invalid params", %{conn: conn} do
		brand = Factory.insert(:brand)

		conn = 
			post conn, brand_detail_path(conn, :create, brand.id),
			detail: %{name: false, slug: 12.23}

		assert conn.status == 422		
	end
end