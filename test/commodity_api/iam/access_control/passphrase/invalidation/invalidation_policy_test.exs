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
defmodule Commodity.Api.Iam.AccessControl.Passphrase.InvalidationPolicyTest do
	use Commodity.ConnCase

	alias Commodity.Factory

	@moduletag login: :user_two

	test "options/1 method", %{conn: conn} do
		conn = 
			options conn,
				iam_user_invalidation_path(conn, :create, 1)

		assert conn.status == 204		
	end

	test "create a passhrase invalidation with valid params",
		%{conn: conn, user: user} do
		permission_set = Repo.get_by!(PermissionSet, name: "Self")
		Factory.insert(:permission_set_grant, user: user, target_user: user,
					permission_set: permission_set)
		
		passphrase = Factory.insert(:user_passphrase, user: user)

		conn = 
			post conn,
				iam_user_invalidation_path(conn, :create, user.id),
				passphrase_ids: [passphrase.id]

		assert conn.status == 201		
	end

	test "should be 403 error create a passphrase 
		invalidation with valid param", %{conn: conn, user: user} do
		permission_set = Repo.get_by!(PermissionSet, name: "Self")
		Factory.insert(:permission_set_grant, user: user, target_user: user,
					permission_set: permission_set)
		
		user = Factory.insert(:user)
		passphrase = Factory.insert(:user_passphrase, user: user)

		conn =
			post conn,
				iam_user_invalidation_path(conn, :create, user.id),
				passphrase_ids: [passphrase.id]

		assert conn.status == 403		
	end
end