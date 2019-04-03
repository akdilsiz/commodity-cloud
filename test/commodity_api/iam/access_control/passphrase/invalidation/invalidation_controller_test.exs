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
defmodule Commodity.Api.Iam.AccessControl.Passphrase.InvalidationControllerTest do
	use Commodity.ConnCase

	alias Commodity.Factory

	@moduletag login: :user

	test "options/1", %{conn: conn} do
		conn = options conn, iam_user_invalidation_path(conn, :options, 1)

		assert conn.status == 204
	end

	test "create a passphrase invalidation with valid params", 
		%{conn: conn, user: user} do
		passphrase = Factory.insert(:user_passphrase, user: user)

		conn = 
			post conn,
				iam_user_invalidation_path(conn, :create, user.id),
				passphrase_ids: [passphrase.id]

		data = json_response(conn, 201)["data"]

		assert data["passphrase_ids"] == [passphrase.id]
	end

	test "should be 422 error create a passphrase invalidation with invalid 
		params",
		%{conn: conn, user: user} do
		conn = 
			post conn,
				iam_user_invalidation_path(conn, :create, user.id),
				passphrase_ids: 123

		assert conn.status == 422
	end

	test "should be 404 error create a passphrase invalidation with valid params
		if other user passphrase identifier", %{conn: conn, user: user} do
		base_user = user
		passphrase = Factory.insert(:user_passphrase, user: base_user)

		user = Factory.insert(:user)
		passphrase_two = Factory.insert(:user_passphrase, user: user)

		assert_error_sent 404, fn -> 
			post conn,
				iam_user_invalidation_path(conn, :create, base_user.id),
				passphrase_ids: [passphrase.id, passphrase_two.id]
		end
	end
end