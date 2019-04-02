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
defmodule Commodity.Api.Iam.AccessControl.PermissionSetGrant do
	@moduledoc """
	Defines a permssion set grant
	"""
	use Commodity.Api, :model

	schema "permission_set_grants" do
		belongs_to :permission_set, Commodity.Api.Iam.AccessControl.PermissionSet
		belongs_to :user, Commodity.Api.Iam.User
		belongs_to :target_user, Commodity.Api.Iam.User

		field :inserted_at, :naive_datetime, read_after_writes: true
	end

	def changeset(struct, params \\ %{}) do
		struct
		|> cast(params, [:permission_set_id, :user_id, :target_user_id])
		|> validate_required([:permission_set_id, :user_id, :target_user_id])
		|> foreign_key_constraint(:user_id)
		|> foreign_key_constraint(:target_user_id)
	end
end