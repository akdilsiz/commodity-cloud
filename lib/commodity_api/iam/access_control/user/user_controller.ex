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
defmodule Commodity.Api.Iam.AccessControl.UserController do
	use Commodity.Api, :controller
	
	import Ecto.Changeset, only: [get_field: 2]

	alias Commodity.Api.Iam.User
	alias Commodity.Api.Iam.Generic.CreationCredentials
	alias Commodity.Elastic

	plug :scrub_params, "user" when action in [:create]

	def options(conn, _params), do: send_resp(conn, :no_content, "")

	def create(conn, %{"user" => user_params}) do
		changeset = 
			CreationCredentials.changeset(%CreationCredentials{}, user_params)
			|> validate_virtual!
		
		given_name = get_field(changeset, :given_name)
		family_name = get_field(changeset, :family_name)
		email = get_field(changeset, :email)
		phone_number = get_field(changeset, :phone_number)
		gender = get_field(changeset, :gender)
		nationality = get_field(changeset, :nationality)
		birthday = get_field(changeset, :birthday)

		transaction = Repo.transaction(fn ->
			user = Repo.insert!(%User{})

			changeset = 
				User.PersonalInformation.changeset(%User.PersonalInformation{},
					%{user_id: user.id,
					source_user_id: user.id,
					given_name: given_name,
					family_name: family_name,
					gender: gender,
					nationality: nationality,
					birthday: birthday})

			personal_information = Repo.insert!(changeset)

			{:ok, "OK"} = 
				Rediscl.Query.set("#{@redis_keys[:user].personal_information.one}:" <>
					"#{user.id}", Jason.encode!(personal_information))

			changeset = 
				User.Email.changeset(%User.Email{},
					%{user_id: user.id,
					value: email})

			{status, email} = Repo.insert(changeset)

			if status == :error do
				Repo.rollback(email)
			end

			Repo.insert!(%User.Email.Primary{email_id: email.id, user_id: user.id})

			{:ok, "1"} =
				Rediscl.Query.sadd("#{@redis_keys[:user].email.all}:#{user.id}",
					[Jason.encode!(email)])

			{:ok, "OK"} =
				Rediscl.Query.set("#{@redis_keys[:user].email.one}:#{user.id}:" <>
					"#{email.id}", Jason.encode!(email))

			changeset = 
				User.PhoneNumber.changeset(%User.PhoneNumber{},
					%{user_id: user.id,
					value: phone_number,
					type: "mobile"})

			phone_number = Repo.insert!(changeset)

			Repo.insert!(%User.PhoneNumber.Primary{number_id: phone_number.id,
				user_id: user.id})

			{:ok, "1"} = 
				Rediscl.Query.sadd("#{@redis_keys[:user].phone_number.all}:#{user.id}",
					[Jason.encode!(phone_number)])

			{:ok, "OK"} =
				Rediscl.Query.set("#{@redis_keys[:user].phone_number.one}:#{user.id}" <>
					":#{phone_number.id}", Jason.encode!(phone_number))

			changeset = User.State.changeset(%User.State{},
				%{user_id: user.id, value: "active",
				source_user_id: user.id})

			Repo.insert!(changeset)

			{:ok, _} =
				Elastic.put("/user/_doc/#{user.id}",
					%{id: user.id,
					personal_information: personal_information,
					phone_numbers: [%{value: phone_number.value,
										type: phone_number.type,
										primary: true}],
					emails: [%{value: email.value, primary: true}],
					inserted_at: user.inserted_at})

			Map.merge(user, %{emails: [Map.put(email, :primary, true)], 
				phone_numbers: [Map.put(phone_number, :primary, :true)],
				personal_information: personal_information})
		end)

		case transaction do
			{:ok, user} ->
				conn
				|> put_status(:created)
				|> render("show.json",
					user: %{one: user,
						time_information: conn.assigns[:time_information]})
			{:error, changeset} ->
				conn
				|> put_status(:unprocessable_entity)
				|> put_view(Commodity.Api.Util.ChangesetView)
				|> render("error.json", changeset: changeset)
		end
	end
end