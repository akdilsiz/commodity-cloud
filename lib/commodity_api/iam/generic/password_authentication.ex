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
defmodule Commodity.Api.Iam.Generic.PasswordAuthentication do
	@moduledoc """
	Defines credential based authentcation functions to authentication user
	"""
	import Plug.Conn, only: [put_resp_header: 3, put_resp_cookie: 4, assign: 3]

	alias Commodity.Api.Iam.User
	alias Commodity.Api.Util.JWTView

	def issue_token(conn, user = %User{}, passphrase) do
		JWTView.render("jwt.json", user: user, passphrase: passphrase)
		|> finalize(conn)
	end

	defp finalize(jwt_view, conn) do
		jwk = %{
		  "kty" => "oct",
		  "k" => Keyword.fetch!(Application.get_env(:commodity, :jwk),
		                        :secret_key_base)
		}

		jws = %{
		  "alg" => "HS256",
		  "typ" => "JWT"
		}

		issuer = Keyword.fetch!(Application.get_env(:commodity, :jwt), :iss)
		expire =
		  :os.system_time(:seconds) +
		  Keyword.fetch!(Application.get_env(:commodity, :jwt), :exp)

		payload = %{"iss" => issuer,
		            "exp" => expire,
		            "sub" => "access"}

		jwt =
		  payload
		  |> Map.merge(jwt_view)

		{_, token} =
		  JOSE.JWT.sign(jwk, jws, jwt)
		  |> JOSE.JWS.compact()

		conn
		|> put_resp_header("authorization", "Bearer #{token}")
		|> assign(:jwt, token)
		|> put_resp_cookie("jwt", token, http_only: true, max_age: expire)
		|> put_resp_header("x-expires", Integer.to_string(jwt["exp"]))
		|> assign(:exp, jwt["exp"])
	end
end