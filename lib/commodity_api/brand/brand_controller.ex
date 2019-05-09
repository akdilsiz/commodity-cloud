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

	import Ecto.Changeset, only: [get_field: 2, add_error: 3]

	alias Commodity.Api.Brand.Detail
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

		{:ok, details} = Rediscl.Query.mget(Enum.map(brands, 
				&"#{@redis_keys[:brand].detail}:#{&1.id}"))

		details = 
			Enum.filter(details, &(&1 != :undefined))
			|> Enum.map(&Jason.decode!(&1, [{:keys, :atoms!}]))

		brand_ids = Enum.map(brands, &(&1.id)) -- Enum.map(details, &(&1.brand_id))

		details =
			if Enum.count(brand_ids) > 0 do
				query = from bd in Detail,
								left_join: bd2 in Detail,
									on: bd.brand_id == bd2.brand_id and
											bd.id < bd2.id,
								where: is_nil(bd2.id) and
												bd.brand_id in ^brand_ids,
								select: bd

				Enum.map(Repo.all(query), fn x -> 
					{x.brand_id, x}
				end) ++ Enum.map(details, fn x -> 
					{x.brand_id, x}
				end)
				|> Enum.into(%{})
			else
				Enum.map(details, &{&1.brand_id, &1})
				|> Enum.into(%{})
			end

		brands = Enum.map(brands, &Map.put(&1, :detail,
			Map.get(details, &1.id, nil)))

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
					brand = Jason.decode!(brand, [{:keys, :atoms!}])

					detail =
						case Rediscl.Query.get("#{@redis_keys[:brand].detail}:#{id}") do
							{:ok, detail} ->
								Jason.decode!(detail, [{:keys, :atoms!}])
							{:error, _} ->
								query = from bd in Detail,
												left_join: bd2 in Detail,
													on: bd.brand_id == bd2.brand_id and
															bd.id < bd2.id,
												where: is_nil(bd2.id) and
																bd.brand_id == ^id,
												select: bd

								detail = Repo.one!(query)

								Rediscl.Query.set("#{@redis_keys[:brand].detail}:#{id}",
									Jason.encode!(detail))

								detail
						end

					Map.put(brand, :detail, detail)
				{:error, _} ->
					query = from b in Brand,
									join: bd in Detail,
										on: b.id == bd.brand_id,
									left_join: bd2 in Detail,
										on: bd.brand_id == bd2.brand_id and
												bd.id < bd2.id,
									where: is_nil(bd2.id) and
													b.id == ^id,
									select: {b, bd}

					{brand, detail} = Repo.one!(query)

					Rediscl.Query.set("#{@redis_keys[:brand].one}:#{brand.id}",
						Jason.encode!(brand))

					Rediscl.Query.set("#{@redis_keys[:brand].detail}:#{brand.id}",
						Jason.encode!(detail))

					Map.put(brand, :detail, detail) 	
			end

		render conn,
			"show.json",
			brand: %{one: brand,
			time_information: conn.assigns[:time_information]}
	end

	def create(conn, %{"brand" => brand_params}) do
		changeset = Brand.changeset(%Brand{}, brand_params)

		transaction = Repo.transaction(fn -> 
			if is_nil(get_field(changeset, :detail)) do
				Repo.rollback(add_error(changeset, :detail, "is not nil"))
			end

			brand = Repo.insert!(changeset)

			detail = 
				get_field(changeset, :detail)
				|> Map.put("brand_id", brand.id)
				|> Map.put("source_user_id", conn.assigns[:user_id])

			changeset = Detail.changeset(%Detail{}, detail)

			{status, detail} = Repo.insert(changeset)

			if status == :error do
				Repo.rollback(detail)
			end

			{:ok, "OK"} =
				Rediscl.Query.set("#{@redis_keys[:brand].one}:#{brand.id}",
					Jason.encode!(brand))

			{:ok, "OK"} =
				Rediscl.Query.set("#{@redis_keys[:brand].detail}:#{brand.id}",
					Jason.encode!(detail))

			Map.put(brand, :detail, detail)
		end)

		case transaction do
			{:ok, brand} ->
				conn
				|> put_status(:created)
				|> render("show.json", brand: %{one: brand,
					time_information: conn.assigns[:time_information]})
			{:error, changeset} ->
				conn
				|> put_status(:unprocessable_entity)
				|> put_view(ChangesetView)
				|> render("error.json", changeset: changeset)
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