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
defmodule Commodity.Api.Generic.PermissionSetGenerate do
	@moduledoc """
	Module of generate permission and default permission set
	"""
	alias Commodity.Api.Iam.AccessControl.Permission
	alias Commodity.Api.Iam.AccessControl.PermissionSet
	alias Commodity.Api.Iam.AccessControl.PermissionSetGrant

	import Ecto.Query

	def clean_and_generate(repo) do
		clean(repo)
		generate(repo)
	end

	def clean(repo) do
		repo.delete_all(PermissionSet)
	end

	def generate(repo) do
		query = from p in Permission,
						where: p.type in ["all", "self"]

		permissions =
			repo.all(query)
			|> Enum.map(fn x -> x.id end)

		if Enum.count(permissions) > 0 do
			changeset =
				PermissionSet.changeset(%PermissionSet{},
																%{name: "Superadmin",
																description: "A permission set with Super Admin",
																permission_ids: permissions,
																user_id: 1})

			permission_set = repo.insert!(changeset)


			repo.insert!(%PermissionSetGrant{permission_set_id: permission_set.id,
																			user_id: 1,
																			target_user_id: 1})
		end

		# Self Permissions
		query = from p in Permission,
						where: p.type == "self"

		permissions =
			repo.all(query)
			|> Enum.map(fn x -> x.id end)

		if Enum.count(permissions) > 0 do
			changeset =
				PermissionSet.changeset(%PermissionSet{},
																%{name: "Self",
																description: "A permission set for Self",
																permission_ids: permissions,
																user_id: 1})

			repo.insert!(changeset)
		end
	end
end