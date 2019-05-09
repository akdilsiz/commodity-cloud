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
defmodule Commodity.Api.Brand.DetailController do
	use Commodity.Api, :controller

	alias Commodity.Api.Brand.Detail

	plug :authentication
	plug :authorized, [:all]
	plug :apply_policy
	plug :scrub_params, "detail" when action in [:create]

	def options(conn, _params), do: send_resp(conn, :no_content, "")

	def create(conn, %{"brand_id" => brand_id, "detail" => detail_params}) do
		detail_params = 
			Map.put(detail_params, "brand_id", brand_id)
			|> Map.put("source_user_id", conn.assigns[:user_id])

		changeset = Detail.changeset(%Detail{}, detail_params)

		transaction = Repo.transaction(fn -> 
			{status, detail} = Repo.insert(changeset)

			if status == :error do
				Repo.rollback(detail)
			end

			{:ok, "OK"} =
				Rediscl.Query.set("#{@redis_keys[:brand].detail}:#{brand_id}",
					Jason.encode!(detail))

			detail
		end) 

		case transaction do
			{:ok, detail} ->
				conn
				|> put_status(:created)
				|> render("show.json", detail: %{one: detail,
					time_information: conn.assigns[:time_information]})
			{:error, changeset} ->
				conn
				|> put_status(:unprocessable_entity)
				|> put_view(ChangesetView)
				|> render("error.json", changeset: changeset)
		end
	end
end