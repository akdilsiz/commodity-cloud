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
defmodule Commodity.Api.Iam.AccessControl.PermissionSet do
	@moduledoc """
	Defines a permssion set
	"""
	use Commodity.Api, :model

	alias Commodity.Repo
	alias Commodity.Api.Iam.AccessControl.Permission

	schema "permission_sets" do
		belongs_to :user, Commodity.Api.Iam.User
		field :name, :string
		field :description, :string
		field :inserted_at, :naive_datetime, read_after_writes: true

		has_many :users, {"permission_sets_users", Commodity.Api.Iam.User}

		many_to_many :permissions,
		              Commodity.Api.Iam.AccessControl.Permission,
		              join_through: "permission_set_permissions"

		field :permission_ids, {:array, :integer}, virtual: true
	end

	def changeset(struct, params \\ %{}) do
		struct
		|> cast(params, [:name, :description, :user_id, :permission_ids])
		|> validate_required([:name, :description, :user_id, :permission_ids])
		|> unique_constraint(:name,
			name: :permission_sets_name_unique)
		|> foreign_key_constraint(:user_id)
		|> put_permission_assoc
	end

	defp put_permission_assoc(changeset) do
		if permission_ids = get_change(changeset, :permission_ids) do
		  permissions =
		    Permission
		    |> where([p], p.id in ^Enum.uniq(permission_ids))
		    |> Repo.all

		  if Enum.count(permissions) == Enum.count(permission_ids) and
		      Enum.count(permissions) != 0,
		    do: put_assoc(changeset, :permissions, permissions),
		  else: add_error(changeset, :permission_ids, "is empty")
		else
		  changeset
		end
	end
end