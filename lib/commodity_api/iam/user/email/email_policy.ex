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
defmodule Commodity.Api.Iam.User.EmailPolicy do
	use Commodity.Api, :policy

	def index(conn, params, :self) do
		policy(conn, params["user_id"])
	end

	def show(conn, params, :self) do
		policy(conn, params["user_id"])
	end

	def create(conn, params, :self) do
		policy(conn, params["user_id"])
	end

	def update(conn, params, :self) do
		policy(conn, params["user_id"])
	end

	def delete(conn, params, :self) do
		policy(conn, params["user_id"])
	end

	defp policy(conn, user_id) do
		conn.assigns[:user_id] == String.to_integer(user_id)
	end
end