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
defmodule Commodity.Api.Iam.User.PhoneNumberController do
	use Commodity.Api, :controller

	alias Commodity.Api.Iam.User.PhoneNumber

	plug :authentication
	plug :authorized, [:all, :self]
	plug :apply_policy
	plug :scrub_params, "phone_number" when action in [:create, :update]

	def options(conn, _params), do: send_resp(conn, :no_content, "")

	def index(conn, %{"user_id" => user_id}) do
		phone_numbers = 
			case Rediscl.Query.smembers("#{@redis_keys[:user].phone_number.all}:" <>
				"#{user_id}") do
				{:ok, phone_numbers} when phone_numbers != [] ->
					phone_numbers = 
						Enum.map(phone_numbers, &Jason.decode!(&1, [{:keys, :atoms!}]))

					primary =
						case Rediscl.Query.get("#{@redis_keys[:user].phone_number.primary}:" <>
							"#{user_id}") do
							{:ok, primary} ->
								String.to_integer(primary)
							{:error, _} ->
								nil
						end

					Enum.map(phone_numbers, &Map.put(&1, :primary, &1.id == primary))
				_ ->
					query = from upn in PhoneNumber,
									where: upn.user_id == ^user_id,
									preload: :primary

					phone_numbers = Repo.all(query)

					Rediscl.Query.sadd("#{@redis_keys[:user].phone_number.all}:#{user_id}",
						Enum.map(phone_numbers, &Jason.encode!(&1)))

					Enum.map(phone_numbers, 
						&["#{@redis_keys[:user].phone_number.one}:#{user_id}:#{&1.id}", 
						Jason.encode!(&1)])
					|> Rediscl.Query.mset

					Enum.filter(phone_numbers, &(&1.primary != nil))
					|> case do
						[phone_number] ->
							Rediscl.Query.set("#{@redis_keys[:user].phone_number.primary}: " <>
								"#{user_id}", phone_number.id)
						_ -> :ok
					end

					phone_numbers
			end

		total_count = Enum.count(phone_numbers)

		render conn,
			"index.json",
			phone_numbers: %{all: phone_numbers,
				total_count: total_count,
				time_information: conn.assigns[:time_information]}
	end

	def show(conn, %{"user_id" => user_id, "id" => id}) do
		phone_number =
			case Rediscl.Query.get("#{@redis_keys[:user].phone_number.one}:" <>
				"#{user_id}:#{id}") do
				{:ok, phone_number} ->
					phone_number = Jason.decode!(phone_number, [{:keys, :atoms!}])

					primary =
						case Rediscl.Query.get("#{@redis_keys[:user].phone_number.primary}:" <>
							"#{user_id}") do
							{:ok, primary} ->
								String.to_integer(primary)
							{:error, _} ->
								nil
						end

					Map.put(phone_number, :primary, phone_number.id == primary)
				{:error, _} ->
					query = from upn in PhoneNumber,
									where: upn.user_id == ^user_id and
													upn.id == ^id,
									preload: :primary

					phone_number = Repo.one!(query)

					Rediscl.Query.set("#{@redis_keys[:user].phone_number.one}:" <>
						"#{user_id}:#{phone_number.id}", Jason.encode!(phone_number))

					if !is_nil(phone_number.primary) do
						Rediscl.Query.set("#{@redis_keys[:user].phone_number.primary}:" <>
							"#{user_id}", phone_number.id)
					end

					phone_number
			end

		render conn,
			"show.json",
			phone_number: %{one: phone_number,
				time_information: conn.assigns[:time_information]}
	end

	def create(conn, %{"user_id" => user_id, 
		"phone_number" => phone_number_params}) do
		phone_number_params = Map.put(phone_number_params, "user_id", user_id)

		changeset = PhoneNumber.changeset(%PhoneNumber{}, phone_number_params)

		transaction = Repo.transaction(fn -> 
			{status, phone_number} = Repo.insert(changeset)

			if status == :error do
				Repo.rollback(phone_number)
			end

			Repo.insert!(PhoneNumber.Log.changeset(%PhoneNumber.Log{
				user_id: phone_number.user_id, number_id: phone_number.id, 
				source_user_id: conn.assigns[:user_id]}))

			Rediscl.Query.sadd("#{@redis_keys[:user].phone_number.all}:#{user_id}",
				[Jason.encode!(phone_number)])

			Rediscl.Query.set("#{@redis_keys[:user].phone_number.one}:#{user_id}:" <>
				"#{phone_number.id}", Jason.encode!(phone_number))

			Map.put(phone_number, :primary, false)
		end)

		case transaction do
			{:ok, phone_number} ->
				conn
				|> put_status(:created)
				|> render("show.json", phone_number: %{one: phone_number,
					time_information: conn.assigns[:time_information]})
			{:error, changeset} ->
				conn
				|> put_status(:unprocessable_entity)
				|> put_view(ChangesetView)
				|> render("error.json", changeset: changeset)
		end
	end

	def update(conn, %{"user_id" => user_id, "id" => id,
		"phone_number" => phone_number_params}) do
		current_phone_number = Repo.get_by!(PhoneNumber, id: id, user_id: user_id)

		phone_number_params = Map.put(phone_number_params, "user_id", user_id)

		changeset = PhoneNumber.changeset(current_phone_number, phone_number_params)

		transaction = Repo.transaction(fn -> 
			{status, phone_number} = Repo.update(changeset)

			if status == :error do
				Repo.rollback(phone_number)
			end

			Repo.insert!(PhoneNumber.Log.changeset(%PhoneNumber.Log{
				user_id: phone_number.user_id, number_id: phone_number.id, 
				source_user_id: conn.assigns[:user_id]}))

			{:ok, "1"} = 
				Rediscl.Query.srem("#{@redis_keys[:user].phone_number.all}:#{user_id}",
					Jason.encode!(current_phone_number))

			Rediscl.Query.sadd("#{@redis_keys[:user].phone_number.all}:#{user_id}",
				[Jason.encode!(phone_number)])

			Rediscl.Query.set("#{@redis_keys[:user].phone_number.one}:#{user_id}:" <>
				"#{phone_number.id}", Jason.encode!(phone_number))

			Map.put(phone_number, :primary, false)
		end)

		case transaction do
			{:ok, phone_number} ->
				render conn, 
					"show.json", 
					phone_number: %{one: phone_number,
						time_information: conn.assigns[:time_information]}
			{:error, changeset} ->
				conn
				|> put_status(:unprocessable_entity)
				|> put_view(ChangesetView)
				|> render("error.json", changeset: changeset)
		end
	end

	def delete(conn, %{"user_id" => user_id, "id" => id}) do
		query = from upn in PhoneNumber,
						where: upn.user_id == ^user_id and
										upn.id == ^id,
						preload: :primary

		phone_number = Repo.one!(query)

		if !is_nil(phone_number.primary) do
			raise Commodity.Api.Util.Error.InvalidPrimaryError
		end

		Repo.transaction(fn -> 
			Repo.delete!(phone_number)

			{:ok, "1"} =
				Rediscl.Query.srem("#{@redis_keys[:user].phone_number.all}:#{user_id}",
					Jason.encode!(phone_number))

			{:ok, "1"} =
				Rediscl.Query.del("#{@redis_keys[:user].phone_number.one}:" <>
					"#{user_id}:#{id}")
		end)

		send_resp(conn, :no_content, "")
	end
end