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
defmodule Commodity.Api.Iam.AccessControl.Permission do
	@moduledoc """
		Define a permission
	"""
	use Commodity.Api, :model

	schema "permissions" do
		field :controller_name, :string
		field :controller_action, :string
		field :type, :string
	end

	def changeset(struct, params \\ %{}) do
		struct
		|> cast(params, [:controller_name, :controller_action, :type])
		|> validate_required([:controller_name, :controller_action, :type])
		|> validate_length(:controller_name, max: 100)
		|> validate_length(:controller_action, max: 30)
		|> unique_constraint(:controller_name,
			name: :permissions_all_unique)
		|> unique_constraint(:controller_action,
			name: :permissions_all_unique)
		|> unique_constraint(:type,
			name: :permissions_all_unique)
	end
end