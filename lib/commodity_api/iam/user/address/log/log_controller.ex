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
defmodule Commodity.Api.Iam.User.Address.LogController do
	use Commodity.Api, :controller

	alias Commodity.Api.Iam.User.Address

	plug :authentication
	plug :authorized, [:all, :self]
	plug :apply_policy

	def options(conn, _params), do: send_resp(conn, :no_content, "")

	def index(conn, %{"user_id" => user_id, "address_id" => address_id}) do
		query = from ual in Address.Log,
						left_join: uai in Address.Invalidation,
							on: ual.address_id == uai.address_id,
						where: is_nil(uai.address_id) and
										ual.user_id == ^user_id and
										ual.address_id == ^address_id,
						select: ual

		logs = Repo.all(query)

		render conn,
			"index.json",
			logs: %{all: logs,
				total_count: Enum.count(logs),
				time_information: conn.assigns[:time_information]}
	end
end