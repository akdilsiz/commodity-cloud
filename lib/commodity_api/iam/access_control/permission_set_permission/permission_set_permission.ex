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
defmodule Commodity.Api.Iam.AccessControl.PermissionSetPermission do
	@moduledoc """
	Defines a permission set permission
	"""
	use Commodity.Api, :model

	schema "permission_set_permissions" do
		belongs_to :permission_set, Commodity.Api.Iam.AccessControl.PermissionSet
		belongs_to :permission, Commodity.Api.Iam.AccessControl.Permission
	end

	def changeset(struct, params \\ %{}) do
		struct
		|> cast(params, [:permission_set_id, :permission_id])
		|> validate_required([:permission_set_id, :permission_id])
		|> unique_constraint(:permission_set_id,
			name: :permission_set_permissions_ps_p_unique)
		|> unique_constraint(:permission_id,
			name: :permission_set_permissions_ps_p_unique)
		|> foreign_key_constraint(:permission_set_id)
		|> foreign_key_constraint(:permission_id)
	end
end