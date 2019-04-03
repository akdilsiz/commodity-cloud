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
defmodule Commodity.Api.Iam.AccessControl.Passphrase.InvalidationController do
	use Commodity.Api, :controller

	import Ecto.Changeset, only: [get_field: 2]

	alias Commodity.Api.Iam.User.Passphrase.Invalidation
	alias Commodity.Api.Iam.User.Passphrase

	alias Commodity.Api.Iam.AccessControl.Passphrase.InvalidationBody

	plug :authentication
	plug :authorized, [:all, :self]
	plug :apply_policy
	plug :scrub_params, "passphrase_ids" when action in [:create]

	def options(conn, _params), do: send_resp(conn, :no_content, "")

	def create(conn, %{"user_id" => user_id, 
										"passphrase_ids" => passphrase_ids_params}) do
		changeset = 
			InvalidationBody.changeset(%InvalidationBody{},
				%{passphrase_ids: passphrase_ids_params})

		transaction = Repo.transaction(fn -> 
			unless changeset.valid? do
				Repo.rollback(changeset)
			end

			query = from p in Passphrase,
							left_join: pi in Passphrase.Invalidation,
								on: p.id == pi.target_passphrase_id,
							where: p.id in ^get_field(changeset, :passphrase_ids) and
											p.user_id == ^user_id and
											is_nil(pi.target_passphrase_id),
							select: p

			unless Repo.aggregate(query, :count, :id) == 
				Enum.count(get_field(changeset, :passphrase_ids)) do
				raise Commodity.Api.Iam.Error.InvalidPassphraseInvalidationNotFound
			end

			passphrases = Repo.all(query)

			Enum.map(passphrases, 
				&%Invalidation{source_passphrase_id: conn.assigns[:passphrase_id],
												target_passphrase_id: &1.id}
				|> Repo.insert!)

			%{passphrase_ids: get_field(changeset, :passphrase_ids)}
		end)

		case transaction do
			{:ok, invalidation} ->
				conn
				|> put_status(:created)
				|> render("show.json", 
					invalidation: %{one: invalidation,
						time_information: conn.assigns[:time_information]})
			{:error, changeset} ->
				conn
				|> put_status(:unprocessable_entity)
				|> put_view(Commodity.Api.Util.ChangesetView)
				|> render("error.json", changeset: changeset)
		end
	end
end