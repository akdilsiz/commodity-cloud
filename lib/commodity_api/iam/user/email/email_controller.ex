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
defmodule Commodity.Api.Iam.User.EmailController do
	use Commodity.Api, :controller

	alias Commodity.Api.Iam.User.Email

	plug :authentication
	plug :authorized, [:all, :self]
	plug :apply_policy
	plug :scrub_params, "email" when action in [:create, :update]

	def options(conn, _params), do: send_resp(conn, :no_content, "")

	def index(conn, %{"user_id" => user_id}) do
		emails = 
			case Rediscl.Query.smembers("#{@redis_keys[:user].email.all}:" <>
				"#{user_id}") do
				{:ok, emails} when emails != [] ->
					emails = Enum.map(emails, &Jason.decode!(&1, [{:keys, :atoms!}]))

					primary =
						case Rediscl.Query.get("#{@redis_keys[:user].email.primary}:" <>
							"#{user_id}") do
							{:ok, primary} ->
								String.to_integer(primary)
							{:error, _} ->
								nil
						end

					Enum.map(emails, &Map.put(&1, :primary, &1.id == primary))
				_ ->
					query = from ue in Email,
									where: ue.user_id == ^user_id,
									preload: :primary

					emails = Repo.all(query)

					Rediscl.Query.sadd("#{@redis_keys[:user].email.all}:#{user_id}",
						Enum.map(emails, &Jason.encode!(&1)))

					Enum.map(emails, 
						&["#{@redis_keys[:user].email.one}:#{user_id}:#{&1.id}", 
						Jason.encode!(&1)])
					|> Rediscl.Query.mset

					Enum.filter(emails, &(&1.primary != nil))
					|> case do
						[email] ->
							Rediscl.Query.set("#{@redis_keys[:user].email.primary}:#{user_id}",
								email.id)
						_ -> :ok
					end

					emails
			end

		total_count = Enum.count(emails)

		render conn,
			"index.json",
			emails: %{all: emails,
				total_count: total_count,
				time_information: conn.assigns[:time_information]}
	end

	def show(conn, %{"user_id" => user_id, "id" => id}) do
		email =
			case Rediscl.Query.get("#{@redis_keys[:user].email.one}:#{user_id}:" <>
				"#{id}") do
				{:ok, email} ->
					email = Jason.decode!(email, [{:keys, :atoms!}])

					primary =
						case Rediscl.Query.get("#{@redis_keys[:user].email.primary}:" <>
							"#{user_id}") do
							{:ok, primary} ->
								String.to_integer(primary)
							{:error, _} ->
								nil
						end

					Map.put(email, :primary, email.id == primary)
				{:error, _} ->
					query = from ue in Email,
									where: ue.user_id == ^user_id and
													ue.id == ^id,
									preload: :primary

					email = Repo.one!(query)

					Rediscl.Query.set("#{@redis_keys[:user].email.one}:#{user_id}:" <>
						"#{email.id}", Jason.encode!(email))

					if !is_nil(email.primary) do
						Rediscl.Query.set("#{@redis_keys[:user].email.primary}:#{user_id}",
							email.id)
					end

					email
			end

		render conn,
			"show.json",
			email: %{one: email,
				time_information: conn.assigns[:time_information]}
	end

	def create(conn, %{"user_id" => user_id, "email" => email_params}) do
		email_params = Map.put(email_params, "user_id", user_id)

		changeset = Email.changeset(%Email{}, email_params)

		transaction = Repo.transaction(fn -> 
			{status, email} = Repo.insert(changeset)

			if status == :error do
				Repo.rollback(email)
			end

			Repo.insert!(Email.Log.changeset(%Email.Log{user_id: email.user_id,
				email_id: email.id, source_user_id: conn.assigns[:user_id]}))

			Rediscl.Query.sadd("#{@redis_keys[:user].email.all}:#{user_id}",
				[Jason.encode!(email)])

			Rediscl.Query.set("#{@redis_keys[:user].email.one}:#{user_id}:#{email.id}",
				Jason.encode!(email))

			Map.put(email, :primary, false)
		end)

		case transaction do
			{:ok, email} ->
				conn
				|> put_status(:created)
				|> render("show.json", email: %{one: email,
					time_information: conn.assigns[:time_information]})
			{:error, changeset} ->
				conn
				|> put_status(:unprocessable_entity)
				|> put_view(ChangesetView)
				|> render("error.json", changeset: changeset)
		end
	end

	def update(conn, %{"user_id" => user_id, "id" => id,
		"email" => email_params}) do
		current_email = Repo.get_by!(Email, id: id, user_id: user_id)

		email_params = Map.put(email_params, "user_id", user_id)

		changeset = Email.changeset(current_email, email_params)

		transaction = Repo.transaction(fn -> 
			{status, email} = Repo.update(changeset)

			if status == :error do
				Repo.rollback(email)
			end

			Repo.insert!(Email.Log.changeset(%Email.Log{user_id: email.user_id,
				email_id: email.id, source_user_id: conn.assigns[:user_id]}))

			{:ok, "1"} = 
				Rediscl.Query.srem("#{@redis_keys[:user].email.all}:#{user_id}",
					Jason.encode!(current_email))

			Rediscl.Query.sadd("#{@redis_keys[:user].email.all}:#{user_id}",
				[Jason.encode!(email)])

			Rediscl.Query.set("#{@redis_keys[:user].email.one}:#{user_id}:#{email.id}",
				Jason.encode!(email))

			Map.put(email, :primary, false)
		end)

		case transaction do
			{:ok, email} ->
				render conn, 
					"show.json", 
					email: %{one: email,
						time_information: conn.assigns[:time_information]}
			{:error, changeset} ->
				conn
				|> put_status(:unprocessable_entity)
				|> put_view(ChangesetView)
				|> render("error.json", changeset: changeset)
		end
	end

	def delete(conn, %{"user_id" => user_id, "id" => id}) do
		query = from ue in Email,
						where: ue.user_id == ^user_id and
										ue.id == ^id,
						preload: :primary

		email = Repo.one!(query)

		if !is_nil(email.primary) do
			raise Commodity.Api.Util.Error.InvalidPrimaryError
		end

		Repo.transaction(fn -> 
			Repo.delete!(email)

			{:ok, "1"} =
				Rediscl.Query.srem("#{@redis_keys[:user].email.all}:#{user_id}",
					Jason.encode!(email))

			{:ok, "1"} =
				Rediscl.Query.del("#{@redis_keys[:user].email.one}:#{user_id}:#{id}")
		end)

		send_resp(conn, :no_content, "")
	end
end