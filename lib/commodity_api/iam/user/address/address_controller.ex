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
defmodule Commodity.Api.Iam.User.AddressController do
	use Commodity.Api, :controller

	alias Commodity.Api.Iam.User.Address

	plug :authentication
	plug :authorized, [:all, :self]
	plug :apply_policy
	plug :scrub_params, "address" when action in [:create, :update]

	def options(conn, _params), do: send_resp(conn, :no_content, "")

	def index(conn, %{"user_id" => user_id}) do
		addresses = 
			case Rediscl.Query.smembers("#{@redis_keys[:user].address.all}:" <>
				"#{user_id}") do
					{:ok, addresses} when addresses != [] ->
						addresses = 
							Enum.map(addresses, &Jason.decode!(&1, [{:keys, :atoms!}]))

						addresses
					_ ->
						query = from ua in Address,
										left_join: uai in Address.Invalidation,
											on: ua.id == uai.address_id,
										where: is_nil(uai.address_id) and
														ua.user_id == ^user_id,
										select: ua

						addresses = Repo.all(query)

						Rediscl.Query.sadd("#{@redis_keys[:user].address.all}:#{user_id}",
							Enum.map(addresses, &Jason.encode!(&1)))

						Rediscl.Query.mset(Enum.map(addresses, 
							&["#{@redis_keys[:user].address.one}:#{user_id}:#{&1.id}",
								Jason.encode!(&1)]))

						addresses
				end

		total_count = Enum.count(addresses)

		render conn,
			"index.json",
			addresses: %{all: addresses,
				total_count: total_count,
				time_information: conn.assigns[:time_information]}
	end

	def show(conn, %{"user_id" => user_id, "id" => id}) do
		address =
			case Rediscl.Query.get("#{@redis_keys[:user].address.one}:#{user_id}:" <>
				"#{id}") do
				{:ok, address} ->
					Jason.decode!(address, [{:keys, :atoms!}])
				{:error, _} ->
					query = from ua in Address,
									left_join: uai in Address.Invalidation,
										on: ua.id == uai.address_id,
									where: is_nil(uai.address_id) and
													ua.user_id == ^user_id and
													ua.id == ^id,
									select: ua

					address = Repo.one!(query)

					Rediscl.Query.set("#{@redis_keys[:user].address.one}:#{user_id}:" <>
						"#{address.id}", Jason.encode!(address))

					address
			end

		render conn,
			"show.json",
			address: %{one: address,
				time_information: conn.assigns[:time_information]}
	end

	def create(conn, %{"user_id" => user_id, "address" => address_params}) do
		address_params = Map.put(address_params, "user_id", user_id)

		changeset = Address.changeset(%Address{}, address_params)

		transaction = Repo.transaction(fn -> 
			{status, address} = Repo.insert(changeset)

			if status == :error do
				Repo.rollback(address)
			end

			Repo.insert!(Address.Log.changeset(%Address.Log{},
				%{user_id: address.user_id, address_id: address.id,
				source_user_id: conn.assigns[:user_id]}))

			{:ok, "1"} =
				Rediscl.Query.sadd("#{@redis_keys[:user].address.all}:#{user_id}",
					[Jason.encode!(address)])

			{:ok, "OK"} =
				Rediscl.Query.set("#{@redis_keys[:user].address.one}:#{user_id}:" <>
					"#{address.id}", Jason.encode!(address))

			address
		end)

		case transaction do
			{:ok, address} ->
				conn
				|> put_status(:created)
				|> render("show.json", address: %{one: address,
					time_information: conn.assigns[:time_information]})
			{:error, changeset} ->
				conn
				|> put_status(:unprocessable_entity)
				|> put_view(ChangesetView)
				|> render("error.json", changeset: changeset)
		end
	end

	def update(conn, %{"user_id" => user_id, "id" => id,
		"address" => address_params}) do
		current_address = Repo.get_by!(Address, id: id, user_id: user_id)

		address_params = Map.put(address_params, "user_id", user_id)

		changeset = Address.changeset(current_address, address_params)

		transaction = Repo.transaction(fn -> 
			{status, address} = Repo.update(changeset)

			if status == :error do
				Repo.rollback(address)
			end

			Repo.insert!(Address.Log.changeset(%Address.Log{},
				%{user_id: address.user_id, address_id: address.id,
				source_user_id: conn.assigns[:user_id]}))

			{:ok, "1"} =
				Rediscl.Query.srem("#{@redis_keys[:user].address.all}:#{user_id}",
					Jason.encode!(current_address))

			{:ok, "1"} =
				Rediscl.Query.sadd("#{@redis_keys[:user].address.all}:#{user_id}",
					[Jason.encode!(address)])

			{:ok, "OK"} =
				Rediscl.Query.set("#{@redis_keys[:user].address.one}:#{user_id}:" <>
					"#{address.id}", Jason.encode!(address))

			address
		end)

		case transaction do
			{:ok, address} ->
				render conn,
					"show.json",
					address: %{one: address,
						time_information: conn.assigns[:time_information]}
			{:error, changeset} ->
				conn
				|> put_status(:unprocessable_entity)
				|> put_view(ChangesetView)
				|> render("error.json", changeset: changeset)
		end
	end
end