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
defmodule Commodity.Api.Iam.Generic.PasswordAuthenticationTest do
	use Commodity.ConnCase

	alias Commodity.Api.Iam.Generic.PasswordAuthentication
	alias Commodity.Factory

	test "generate jwt conn with given parameters" do
		user = Factory.insert(:user)
		passphrase = Factory.insert(:user_passphrase, user: user)

		conn = Phoenix.ConnTest.build_conn()

		conn = PasswordAuthentication.issue_token(conn, user, passphrase)

		assert !is_nil(conn.assigns.jwt)
	end
end