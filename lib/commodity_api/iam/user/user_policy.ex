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
defmodule Commodity.Api.Iam.UserPolicy do
	use Commodity.Api, :policy

	def index(_conn, _params, _type), do: false

	def show(conn, params, :self) do
		if conn.assigns[:user_id] == String.to_integer(params["id"]) do
			true
		else
			false
		end
	end

	def create(_conn, _params, _type), do: false

	def delete(_conn, _params, _type), do: false
end