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

		total_count = Repo.aggregate(User, :count, :id)

		query = from u in User,
						join: us in User.State,
							on: u.id == us.user_id,
						left_join: us2 in User.State,
							on: us.user_id == us2.user_id and
									us.id < us2.id,
						where: is_nil(us2.id) and
										us.value == ^state,
						limit: ^limit,
						offset: ^offset,
						select: u

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

	def show(conn, %{"id" => id}) do
		user = Repo.get!(User, id)

		render conn,
			"index.json",
			user: %{one: user,
				time_information: conn.assigns[:time_information]}
	end

	def create(conn, %{"user" => user_params}) do
		changeset = User.changeset(%User{}, user_params)

		case Repo.insert(changeset) do
			{:ok, user} ->
				conn
				|> put_status(:created)
				|> render("show.json", user: %{one: user,
					time_information: conn.assigns[:time_information]})
			{:error, changeset} ->
				conn
				|> put_status(:unprocessable_entity)
				|> put_view(ChangesetView)
				|> render("error.json", changeset: changeset)
		end
	end

	def delete(conn, %{"id" => id}) do
		user = Repo.get!(User, id)

		Repo.delete!(user)

		send_resp(conn, :no_content, "")
	end
end