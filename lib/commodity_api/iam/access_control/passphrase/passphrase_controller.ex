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
defmodule Commodity.Api.Iam.AccessControl.PassphraseController do
	use Commodity.Api, :controller

	import Ecto.Changeset, only: [get_field: 2]
	import Comeonin.Bcrypt, only: [checkpw: 2]

	alias Commodity.Api.Iam.User
	alias Commodity.Api.Iam.User.Passphrase
	alias Commodity.Api.Iam.User.PasswordAssignment
	alias Commodity.Api.Iam.User.Email
	alias Commodity.Api.Iam.Generic.Credentials
	alias Commodity.Api.Iam.Generic.Passkey

	plug :scrub_params, "credentials" when action in [:create]

	def options(conn, _params), do: send_resp(conn, :no_content, "")

	def create(conn, %{"credentials" => credential_params}) do
		changeset = 
			Credentials.changeset(%Credentials{}, credential_params)
			|> validate_virtual!

		{:ok, passphrase} = Repo.transaction(fn -> 
			email = get_field(changeset, :email)
			password = get_field(changeset, :password)

			query = from u in User,
							join: upa in PasswordAssignment,
								on: u.id == upa.user_id,
							left_join: upa2 in PasswordAssignment,
								on: upa.user_id == upa2.user_id and
										upa.id < upa2.id,
							join: ue in Email,
								on: u.id == ue.user_id,
							join: uep in Email.Primary,
								on: ue.id == uep.email_id,
							where: is_nil(upa2.id) and
											ue.value == ^email,
							select:	{u.id, upa.password_digest}

			{user_id, password_digest} = Repo.one!(query)

			unless checkpw(password, password_digest) do
				raise Commodity.Api.Iam.Error.InvalidAuthentication
			end

			query = from p in Passphrase,
							left_join: pi in Passphrase.Invalidation,
								on: p.id == pi.target_passphrase_id,
							where: is_nil(pi.target_passphrase_id) and 
											p.user_id == ^user_id and
											p.inserted_at >= ago(6, "month")

			unless Repo.aggregate(query, :count, :id) < 5 do
				raise Commodity.Api.Iam.Error.InvalidPassphraseQuota
			end

			changeset = Passphrase.changeset(%Passphrase{},
																			%{user_id: user_id,
																				passphrase: Passkey.generate})

			passphrase = Repo.insert!(changeset)

			passphrase
		end)

		conn
		|> put_status(:created)
		|> render("show.json", 
			passphrase: %{one: passphrase,
				time_information: conn.assigns[:time_information]})
	end
end