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
defmodule Commodity.ElasticTest do
	use Commodity.LibraryCase

	alias Commodity.Elastic

	test "elastic server get info" do
		{:ok, body} = Elastic.get("")

		assert body["cluster_name"]
		assert body["version"]
	end

	test "elastic server get query" do
		{:ok, body} = Elastic.get("/", %{})

		assert body
	end

	test "put index elastic api" do
		user = %{username: "akdilsiz"}

		{:ok, body} = Elastic.put("/commodity/user/1", user)

		assert body
	end

	test "bulk put index elasctic api" do
		users =
			for x <- 1..10 do
				%{index: %{_index: "commodity",
						_type: "user",
						_id: x},
						fields: %{username: "akdilsiz#{x}"}}
			end

		{:ok, body} =  Elastic.put("/_bulk", users)

		assert Enum.count(body["items"]) == 10
	end

	test "bulk put index with method elasctic api" do
		users =
			for x <- 1..10 do
				%{index: %{_index: "commodity",
						_type: "user",
						_id: x},
						fields: %{username: "akdilsiz#{x}"}}
			end

		{:ok, body} =  Elastic.put("/_bulk", users, :put)

		assert body
	end

	test "put request with given data and method" do
		{:ok, body} = Elastic.put("/commodity/user/1", %{username: "akdilsiz"},
								:put)

		assert body
	end

	test "update query put elastic api" do
		{:ok, _body} = Elastic.delete("/user")

		parent = self()

		Task.start_link(fn ->
			users =
				for x <- 1..50 do
				ids =
					Enum.map(1..50, fn y ->
						y
					end)
					|> Enum.shuffle

					%{index: %{_index: "user",
								_type: "info",
								_id: x},
								fields: %{ids: ids}}
				end

			{:ok, body} =  Elastic.put("/_bulk", users)

			if Enum.count(body["items"]) == 50 do
				send parent, :process_done
			end
		end)

		receive do
			:procees_done -> :ok
		after
			3000 ->
				{:ok, body} = Elastic.get("/user/info/_search?q=ids:50")

				assert body["hits"]["total"] == 50

				{:ok, _body} = Elastic.put("/user/info",
										%{key: "ids",
										value: 50},
										:query,
										:bulk_update_in_array_field_remove)

				# assert body["updated"] == 50
		end
	end

	test "delete index elastic api" do
		user = %{user_id: 1, username: "akdilsiz"}

		{:ok, body} = Elastic.put("/commodity/user/2", user)

		assert body

		{:ok, body} = Elastic.delete("/commodity/user/2")

		assert body
	end
end