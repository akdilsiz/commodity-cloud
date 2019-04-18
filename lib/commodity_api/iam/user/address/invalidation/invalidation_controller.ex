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
defmodule Commodity.Api.Iam.User.Address.InvalidationController do
	use Commodity.Api, :controller

	alias Commodity.Api.Iam.User.Address

	plug :authentication
	plug :authorized, [:all, :self]
	plug :apply_policy

	def options(conn, _params), do: send_resp(conn, :no_content, "")

	def create(conn, %{"user_id" => user_id, "address_id" => id}) do
		query = from ua in Address,
						where: ua.user_id == ^user_id and
										ua.id == ^id,
						select: ua

		address = Repo.one!(query)

		changeset = Address.Invalidation.changeset(%Address.Invalidation{},
			%{address_id: address.id, user_id: user_id, 
			source_user_id: conn.assigns[:user_id]})

		transaction = Repo.transaction(fn -> 
			{status, invalidation} = Repo.insert(changeset)

			if status == :error do
				Repo.rollback(invalidation)
			end

			{:ok, "1"} =
				Rediscl.Query.srem("#{@redis_keys[:user].address.all}:#{user_id}",
					Jason.encode!(address))

			{:ok, "1"} =
				Rediscl.Query.del("#{@redis_keys[:user].address.one}:#{user_id}:" <>
					"#{address.id}")

			invalidation
		end)

		case transaction do
			{:ok, _} ->
				send_resp(conn, :created, "")
			{:error, changeset} ->
				conn
				|> put_status(:unprocessable_entity)
				|> put_view(ChangesetView)
				|> render("error.json", changeset: changeset)
		end
	end
end