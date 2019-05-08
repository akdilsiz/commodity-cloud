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
defmodule Commodity.Api.BrandPolicyTest do
	use Commodity.ConnCase

	alias Commodity.Factory

	@moduletag login: :user_two

	test "should be 403 error create a brand with self permission", 
		%{conn: conn, user: user} do
		permission_set = Repo.get_by!(PermissionSet, name: "Self")
		Factory.insert(:permission_set_grant, user: user, target_user: user,
			permission_set: permission_set)

		conn = post conn, brand_path(conn, :create), brand: %{}

		assert conn.status == 403		
	end

	test "should be 403 error delete a brand with given identifier and self " <>
		"permission", %{conn: conn, user: user} do
		permission_set = Repo.get_by!(PermissionSet, name: "Self")
		Factory.insert(:permission_set_grant, user: user, target_user: user,
			permission_set: permission_set)	

		conn = delete conn, brand_path(conn, :delete, 99_999_999)

		assert conn.status == 403
	end
end