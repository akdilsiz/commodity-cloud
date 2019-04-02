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
defmodule Commodity.Api.Iam.Generic.AuthenticationPlug do
	@moduledoc """
	Authentication provides plug for users
	"""
	use Commodity.Api, :plug

	@secret_key_base Keyword.fetch!(Application.get_env(:commodity, :jwk), :secret_key_base)

	defp authenticate(conn, hook) do
		jwk = JOSE.JWK.from(%{"kty" => "oct", "k" => @secret_key_base})

		{hook, token_exp} =
			case get_req_header(conn, "authorization") do
				["Bearer " <> token ] ->
					case JOSE.JWS.verify(jwk, token) do
						{true, payload, _jws} ->
							{hook.(Jason.decode!(payload)), 
								Jason.decode!(payload)["exp"]}
						_ ->
							raise Commodity.Api.Iam.Error.InvalidAuthenticationToken
					end
				_ ->
					raise Commodity.Api.Iam.Error.InvalidAuthenticationTokenNotFound									
			end

		case :os.system_time(:seconds) > token_exp do
			true ->
				raise Commodity.Api.Iam.Error.InvalidAuthenticationTokenExpire
			false ->
				hook
		end
	end

	@doc """
	Authentcation user from request header named 'authorization'
	"""
	@spec authentication(Plug.Conn.t, Keyword.t) ::
		Plug.Conn.t
	def authentication(conn, _opts) do
		authenticate(conn, fn payload ->
			conn
			|> assign(:passphrase_id, payload["passphrase_id"])
			|> assign(:user_id, payload["user_id"])
		end)
	end
end