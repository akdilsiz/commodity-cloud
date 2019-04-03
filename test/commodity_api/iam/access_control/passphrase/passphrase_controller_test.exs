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
defmodule Commodity.Api.Iam.AccessControl.PassphraseControllerTest do
	use Commodity.ConnCase

	import Comeonin.Bcrypt, only: [hashpwsalt: 1]

	alias Commodity.Api.Iam.Generic.Passkey
	alias Commodity.Factory

	test "options/0", %{conn: conn} do
		conn = options conn, iam_passphrase_path(conn, :options)

		assert conn.status == 204
	end

	test "create a passphrase with username and password params", %{conn: conn} do
		user = Factory.insert(:user)
		Factory.insert(:user_personal_information, user: user)
		email = Factory.insert(:user_email, user: user, 
			value: "akdilsiz@tecpor.com")
		Factory.insert(:user_email_primary, user: user, email: email)
		Factory.insert(:user_password_assignment, 
										user: user,
										password_digest: hashpwsalt("1234"))
		
		conn =
			post conn,
				iam_passphrase_path(conn, :create),
				credentials: %{email: "akdilsiz@tecpor.com", password: "1234"}

		data = json_response(conn, 201)["data"]

		assert data["id"]
		assert data["user_id"] == user.id
		assert data["passphrase"]
	end

	test "create a passphrase with email and password params", %{conn: conn} do
		user = Factory.insert(:user)
		email = Factory.insert(:user_email, user: user,
			value: "akdilsiz@tecpor.com")
		Factory.insert(:user_email_primary, user: user, email: email)
		Factory.insert(:user_email, user: user,
			value: "akdilsiz@gnauk.com")

		Factory.insert(:user_password_assignment, 
			user: user,
			password_digest: hashpwsalt("1234"))
		
		conn =
			post conn,
				iam_passphrase_path(conn, :create),
				credentials: %{email: "akdilsiz@tecpor.com", password: "1234"}

		data = json_response(conn, 201)["data"]

		assert data["id"]
		assert data["user_id"] == user.id
		assert data["passphrase"]
	end

	test "doesnt create a passphrase with invalid params", %{conn: conn} do
		assert_error_sent 422, fn -> 
			post conn,
				iam_passphrase_path(conn, :create),
				credentials: %{email: false, password: 12.3}
		end
	end

	test "doesnt create a passphrase with incorrect password", %{conn: conn} do
		user = Factory.insert(:user)
		Factory.insert(:user_personal_information, user: user)
		email = Factory.insert(:user_email, user: user,
			value: "akdilsiz@tecpor.com")
		Factory.insert(:user_email_primary, user: user, email: email)
		Factory.insert(:user_password_assignment, 
										user: user,
										password_digest: hashpwsalt("1234"))

		assert_error_sent 401, fn -> 
			post conn,
				iam_passphrase_path(conn, :create),
				credentials: %{email: "akdilsiz@tecpor.com", password: "wrongwrong"}
		end
	end

	test "should fail to create passphrase with valid params if max passphrase " <>
		"length is exceeded", %{conn: conn} do
		user = Factory.insert(:user)
		Factory.insert(:user_personal_information, user: user)
		email = Factory.insert(:user_email, user: user,
			value: "akdilsiz@tecpor.com")
		Factory.insert(:user_email_primary, user: user, email: email)
		Factory.insert(:user_password_assignment,
										user: user,
										password_digest: hashpwsalt("1234"))

		Factory.insert(:user_passphrase, user: user,
			passphrase: Passkey.generate())
		Factory.insert(:user_passphrase, user: user,
			passphrase: Passkey.generate())
		Factory.insert(:user_passphrase, user: user,
			passphrase: Passkey.generate())
		Factory.insert(:user_passphrase, user: user,
			passphrase: Passkey.generate())
		Factory.insert(:user_passphrase, user: user,
			passphrase: Passkey.generate())

		assert_error_sent 429, fn -> 
			post conn,
				iam_passphrase_path(conn, :create),
				credentials: %{email: "akdilsiz@tecpor.com", password: "1234"}
		end
	end
end