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
defmodule Commodity.Api.Util.PagingRequest do
	@moduledoc """
	Pagination request artifacts
	"""
	use Commodity.Api, :virtual

	embedded_schema do
		field :limit, :integer, default: 40
		field :offset, :integer, default: 0
		field :order_by, :string, default: "desc"
		field :order_field, :string, default: "id"
		field :type, :string, default: "all"
	end

	def changeset(struct, params \\ %{}, order_field \\ []) do
		struct
		|> cast(params, [:limit, :offset, :order_by, :type])
		|> validate_number(:limit, greater_than: 0, less_than: 41)
		|> validate_inclusion(:order_by, ["asc", "desc"])
		|> validate_inclusion(:order_field, order_field)
		|> validate_inclusion(:type, ["all"])
	end
end