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
defmodule Commodity.Api.Iam.User.StateController do
	use Commodity.Api, :controller

	alias Commodity.Api.Iam.User.State

	plug :authentication
	plug :authorized, [:all]
	plug :apply_policy
	plug :scrub_params, "state" when action in [:create]

	def options(conn, _params), do: send_resp(conn, :no_content, "")

	def create(conn, %{"user_id" => user_id, "state" => state_params}) do
		state_params = 
			Map.put(state_params, "user_id", user_id)
			|> Map.put("source_user_id", conn.assigns[:user_id])

		changeset = State.changeset(%State{}, state_params)

		transaction = Repo.transaction(fn -> 
			{status, state} = Repo.insert(changeset)

			if status == :error do
				Repo.rollback(state)
			end

			{:ok, "OK"} =
				Rediscl.Query.set("#{@redis_keys[:user].state}:#{user_id}",
					Jason.encode!(state))

			state
		end)

		case transaction do
			{:ok, state} ->
				conn
				|> put_status(:created)
				|> render("show.json", state: %{one: state,
					time_information: conn.assigns[:time_information]})
			{:error, changeset} ->
				conn
				|> put_status(:unprocessable_entity)
				|> put_view(ChangesetView)
				|> render("error.json", changeset: changeset)
		end
	end
end