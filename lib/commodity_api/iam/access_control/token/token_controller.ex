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
defmodule Commodity.Api.Iam.AccessControl.TokenController do
	use Commodity.Api, :controller

	import Commodity.Api.Iam.Generic.PasswordAuthentication
	import Ecto.Changeset, only: [get_field: 2]

	alias Commodity.Api.Iam.User
	alias Commodity.Api.Iam.Generic.PassphraseSubmission
	alias Commodity.Api.Iam.User.Passphrase
	alias Commodity.Api.Iam.User.Passphrase.Invalidation

	plug :scrub_params, "passphrase_submission" when action in [:create]

	def create(conn, 
		%{"passphrase_submission" => passphrase_submission_params}) do
		changeset = 
			PassphraseSubmission.changeset(%PassphraseSubmission{},
				passphrase_submission_params)
			|> validate_virtual!

		query = from p in Passphrase,
						left_join: pi in Invalidation,
							on: p.id == pi.target_passphrase_id,
						join: u in User,
							on: p.user_id == u.id,
						where: p.passphrase == ^get_field(changeset, :passphrase) and
									is_nil(pi.target_passphrase_id) and
									p.inserted_at >= ago(6, "month"),
						select: {u, p}
		
		{user, passphrase} = Repo.one!(query)

		conn = issue_token(conn, user, passphrase)

		conn
		|> put_status(:created)
		|> render("show.json", 
			token: %{jwt: conn.assigns[:jwt],	
			expire: conn.assigns[:exp],
			user_id: user.id,
			passphrase_id: passphrase.id})
	end
end