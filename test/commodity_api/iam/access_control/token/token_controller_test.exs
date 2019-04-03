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
defmodule Commodity.Api.Iam.AccessControl.TokenControllerTest do
	use Commodity.ConnCase

	alias Commodity.Api.Iam.Generic.Passkey
	alias Commodity.Factory

	test "should create a token with valid params", %{conn: conn} do
		user = Factory.insert(:user)
		passphrase = Factory.insert(:user_passphrase, user: user,
			passphrase: Passkey.generate())

		conn = 
			post conn, iam_token_path(conn, :create),
				passphrase_submission: %{passphrase: passphrase.passphrase}

		data = json_response(conn, 201)["data"]

		assert data["jwt"]
		assert data["expire"]
		assert data["user_id"] == user.id
		assert data["passphrase_id"] == passphrase.id
	end

	test "should throw 404 create a token with valid params if passphrase 
		is invalidate", %{conn: conn} do
		user = Factory.insert(:user)
		passphrase = Factory.insert(:user_passphrase, user: user,
			passphrase: Passkey.generate)
		Factory.insert(:user_passphrase_invalidation, source_passphrase: passphrase,
				target_passphrase: passphrase)

		assert_error_sent 404, fn -> 
			post conn, iam_token_path(conn, :create),
				passphrase_submission: %{passphrase: passphrase.passphrase}
		end
	end

	test "should throw 404 create a token with valid params if passphrase
		exceeded", %{conn: conn} do
		user = Factory.insert(:user)
		passphrase = Factory.insert(:user_passphrase, 
			user: user,
			passphrase: Passkey.generate,
			inserted_at: NaiveDateTime.from_iso8601!("2018-03-01 12:00:00"))

		assert_error_sent 404, fn -> 
			post conn, iam_token_path(conn, :create),
				passphrase_submission: %{passphrase: passphrase.passphrase}
		end
	end
end