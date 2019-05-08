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
defmodule Commodity.Api.BrandController do
	use Commodity.Api, :controller

	import Ecto.Changeset, only: [get_field: 2]

	alias Commodity.Api.Brand

	plug :authentication when action not in [:index, :show]
	plug :authorized, [:all, :self] when action not in [:index, :show]
	plug :apply_policy when action not in [:index, :show]
	plug :scrub_params, "brand" when action in [:create]

	def options(conn, _params), do: send_resp(conn, :no_content, "")

	def index(conn, params) do
		params = 
			PagingRequest.changeset(%PagingRequest{}, params)
			|> validate_virtual_request!

		limit = get_field(params, :limit)
		offset = get_field(params, :offset)
		order_by = get_field(params, :order_by)

		order =
			case order_by do
				"desc" ->
					[desc: :id]
				"asc" ->
					[asc: :id]
			end

		total_count = Repo.aggregate(Brand, :count, :id)

		query = from b in Brand,
						limit: ^limit,
						offset: ^offset,
						order_by: ^order,
						select: b

		brands = Repo.all(query)

		render conn,
			"index.json",
			brands: %{all: brands,
				total_count: total_count,
				time_information: conn.assigns[:time_information]}
	end

	def show(conn, %{"id" => id}) do
		brand =
			case Rediscl.Query.get("#{@redis_keys[:brand].one}:#{id}") do
				{:ok, brand} ->
					Jason.decode!(brand, [{:keys, :atoms!}])
				{:error, _} ->
					brand = Repo.get!(Brand, id)

					Rediscl.Query.set("#{@redis_keys[:brand].one}:#{brand.id}",
						Jason.encode!(brand))

					brand
			end

		render conn,
			"show.json",
			brand: %{one: brand,
			time_information: conn.assigns[:time_information]}
	end

	def create(conn, %{"brand" => brand_params}) do
		changeset = Brand.changeset(%Brand{}, brand_params)

		transaction = Repo.transaction(fn -> 
			{_status, brand} = Repo.insert(changeset)

			# if status == :error do
			# 	Repo.rollback(brand)
			# end

			{:ok, "OK"} =
				Rediscl.Query.set("#{@redis_keys[:brand].one}:#{brand.id}",
					Jason.encode!(brand))

			brand
		end)

		case transaction do
			{:ok, brand} ->
				conn
				|> put_status(:created)
				|> render("show.json", brand: %{one: brand,
					time_information: conn.assigns[:time_information]})
		end
	end

	def delete(conn, %{"id" => id}) do
		brand = Repo.get!(Brand, id)

		Repo.transaction(fn -> 
			Repo.delete!(brand)

			{:ok, "1"} = Rediscl.Query.del("#{@redis_keys[:brand].one}:#{brand.id}")
		end)

		send_resp(conn, :no_content, "")
	end
end