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
defmodule Commodity.Api.Iam.Generic.AuthenticationPlugTest do
	use Commodity.ConnCase

	import Phoenix.ConnTest, only: [build_conn: 0]
	import Plug.Conn, only: [put_req_header: 3]

	alias Commodity.Api.Iam.Generic.AuthenticationPlug
	alias Commodity.AuthHelper
	alias Commodity.Factory

	test "authentication user with valid param" do
		user = Factory.insert(:user)
		passphrase = Factory.insert(:user_passphrase, user: user)

		conn =
			build_conn()
			|> AuthHelper.issue_token(user, passphrase)
			|> AuthenticationPlug.authentication(nil)

		assert conn.assigns[:user_id] == user.id
		assert conn.assigns[:passphrase_id] == passphrase.id
	end

	test "throws error authentication user if not valid token" do
		assert_raise Commodity.Api.Iam.Error.InvalidAuthenticationToken, fn -> 
			build_conn()
			|> put_req_header("authorization", "Bearer invalid.token")
			|> AuthenticationPlug.authentication(nil)
		end
	end

	test "throws error authentication user if not authenticate" do
		assert_raise Commodity.Api.Iam.Error.InvalidAuthenticationTokenNotFound, fn -> 
			build_conn()
			|> AuthenticationPlug.authentication(nil)
		end
	end

	test "throws error authentication user if token expite" do
		user = Factory.insert(:user)
		passphrase = Factory.insert(:user_passphrase, user: user)

		assert_raise Commodity.Api.Iam.Error.InvalidAuthenticationTokenExpire, fn -> 
			build_conn()
			|> AuthHelper.issue_token(user, passphrase, false)
			|> AuthenticationPlug.authentication(nil)
		end
	end
end