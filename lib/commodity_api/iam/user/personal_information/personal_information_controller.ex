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
defmodule Commodity.Api.Iam.User.PersonalInformationController do
	use Commodity.Api, :controller

	alias Commodity.Api.Iam.User.PersonalInformation

	plug :authentication
	plug :authorized, [:all, :self]
	plug :apply_policy
	plug :scrub_params, "personal_information" when action in [:create]

	def options(conn, _params), do: send_resp(conn, :no_content, "")

	def create(conn, %{"user_id" => user_id, 
		"personal_information" => personal_information_params}) do
		personal_information_params = 
			Map.put(personal_information_params, "user_id", user_id)
			|> Map.put("source_user_id", conn.assigns[:user_id])

		changeset = PersonalInformation.changeset(%PersonalInformation{},
			personal_information_params)

		transaction = Repo.transaction(fn -> 
			{status, personal_information} = Repo.insert(changeset)

			if status == :error do
				Repo.rollback(personal_information)
			end

			{:ok, "OK"} = 
				Rediscl.Query.set("#{@redis_keys[:user].personal_information.one}:" <>
					"#{user_id}", Jason.encode!(personal_information))

			{:ok, _} =
				Elastic.put("/user/_doc/#{user_id}/_update",
					%{doc: %{personal_information: personal_information}})

			personal_information
		end)

		case transaction do
			{:ok, personal_information} ->
				conn
				|> put_status(:created)
				|> render("show.json", 
					personal_information: %{one: personal_information,
						time_information: conn.assigns[:time_information]})
			{:error, changeset} ->
				conn
				|> put_status(:unprocessable_entity)
				|> put_view(ChangesetView)
				|> render("error.json", changeset: changeset)
		end
	end
end