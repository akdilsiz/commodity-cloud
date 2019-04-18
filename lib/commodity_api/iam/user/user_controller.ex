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
defmodule Commodity.Api.Iam.UserController do
	use Commodity.Api, :controller

	import Ecto.Changeset, only: [get_field: 2]

	alias Commodity.Api.Iam.User

	plug :authentication
	plug :authorized, [:all, :self]
	plug :apply_policy
	plug :scrub_params, "user" when action in [:create]

	def options(conn, _params), do: send_resp(conn, :no_content, "")

	def index(conn, params) do
		params = 
			PagingRequest.changeset(%PagingRequest{}, params)
			|> validate_virtual!

		limit = get_field(params, :limit)
		offset = get_field(params, :offset)
		state = get_field(params, :state)
		order_by = get_field(params, :order_by)

		order =
			case order_by do
				"desc" ->
					[desc: :id]
				"asc" ->
					[asc: :id]
			end

		total_count = Repo.aggregate(User, :count, :id)

		query = from u in User,
						join: us in User.State,
							on: u.id == us.user_id,
						left_join: us2 in User.State,
							on: us.user_id == us2.user_id and
									us.id < us2.id,
						left_join: upi in User.PersonalInformation,
							on: u.id == upi.user_id,
						left_join: upi2 in User.PersonalInformation,
							on: upi.user_id == upi2.user_id and
									upi.id < upi2.id,
						where: is_nil(us2.id) and
										is_nil(upi2.id) and
										us.value == ^state,
						limit: ^limit,
						offset: ^offset,
						order_by: ^order,
						select: u,
						select_merge: %{personal_information: upi}

		users = Repo.all(query)

		query = from ue in User.Email,
						where: ue.user_id in ^Enum.map(users, &(&1.id)),
						select: ue,
						preload: :primary

		emails = Repo.all(query)

		query = from upn in User.PhoneNumber,
						where: upn.user_id in ^Enum.map(users, &(&1.id)),
						select: upn,
						preload: :primary

		phone_numbers = Repo.all(query)

		users = Enum.map(users, fn x -> 
			Map.merge(x, %{emails: Enum.filter(emails, &(&1.user_id == x.id)),
				phone_numbers: Enum.filter(phone_numbers, &(&1.user_id == x.id))})
		end)

		render conn,
			"index.json",
			users: %{all: users,
				total_count: total_count,
				time_information: conn.assigns[:time_information]}
	end

	def show(conn, params) do
		show(conn, params["id"], if is_nil(params["state"]) do
			"active"
		else
			params["state"]
		end)
	end

	defp show(conn, user_id, state) do
		user =
			case Rediscl.Query.get("#{@redis_keys[:user].one}:#{user_id}") do
				{:ok, user} ->
					user = Jason.decode!(user, [{:keys, :atoms!}])

					case Rediscl.Query.mget(["#{@redis_keys[:user].state}:#{user_id}",
						"#{@redis_keys[:user].personal_information.one}:#{user_id}"]) do
						{:ok, [:undefined, _]} ->
							raise Commodity.Api.Util.Error.InvalidNotFoundError
						{:ok, [state, personal_information]} ->
							state = Jason.decode!(state, [{:keys, :atoms!}])

							if state.value == "active" do
								Map.put(user, :personal_information, 
									if personal_information == :undefined do
										nil 
									else
										Jason.decode!(personal_information, [{:keys, :atoms!}])
									end)
							else
								raise Commodity.Api.Util.Error.InvalidNotFoundError
							end
					end
				_ ->
					query = from u in User,
									join: us in User.State,
										on: u.id == us.user_id,
									left_join: us2 in User.State,
										on: us.user_id == us2.user_id and
												us.id < us2.id,
									left_join: upi in User.PersonalInformation,
										on: u.id == upi.user_id,
									left_join: upi2 in User.PersonalInformation,
										on: upi.user_id == upi2.user_id and
												upi.id < upi2.id,
									where: is_nil(us2.id) and
													is_nil(upi2.id) and
													us.value == ^state and
													u.id == ^user_id,
									select: u,
									select_merge: %{personal_information: upi}

					user = Repo.one!(query)

					Rediscl.Query.set("#{@redis_keys[:user].one}:#{user.id}",
						Jason.encode!(user))

					user
			end

		render conn,
			"show.json",
			user: %{one: user,
				time_information: conn.assigns[:time_information]}
	end

	def create(conn, %{"user" => user_params}) do
		changeset = User.changeset(%User{}, user_params)

		transaction = Repo.transaction(fn -> 
			user = Repo.insert!(changeset)

			{_, _} = Rediscl.Query.set("#{@redis_keys[:user].one}:#{user.id}",
				Jason.encode!(user))

			{_, _} = Elastic.put("/user/_doc/#{user.id}", user)

			user
		end)

		case transaction do
			{:ok, user} ->
				conn
				|> put_status(:created)
				|> render("show.json", user: %{one: user,
					time_information: conn.assigns[:time_information]})
			# {:error, changeset} ->
			# 	conn
			# 	|> put_status(:unprocessable_entity)
			# 	|> put_view(ChangesetView)
			# 	|> render("error.json", changeset: changeset)
		end
	end

	def delete(conn, %{"id" => id}) do
		user = Repo.get!(User, id)

		Repo.delete!(user)

		{:ok, _} = Rediscl.Query.del("#{@redis_keys[:user].one}:#{user.id}")
		{:ok, _} = Elastic.delete("/user/_doc/#{user.id}")

		send_resp(conn, :no_content, "")
	end
end