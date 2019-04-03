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
defmodule Commodity.Api.Generic.PermissionGenerate do
	@moduledoc """
	Module of generate permission and default permission set
	"""
	alias Commodity.Api.Iam.AccessControl.Permission
	alias Commodity.Api.Iam.AccessControl.PermissionSet

	def clean_and_generate(repo) do
		clean(repo)
		generate(repo)
	end

	def clean(repo) do
		repo.delete_all(Permission)
		repo.delete_all(PermissionSet)

		Ecto.Adapters.SQL.query!(repo, "ALTER SEQUENCE permissions_id_seq RESTART WITH 1;", [])
		Ecto.Adapters.SQL.query!(repo, "ALTER SEQUENCE permission_sets_id_seq RESTART WITH 1;", [])
	end

	def generate(repo) do
		permissions =
			routes()
			|> Enum.map(&permissions_from_router/1)
			|> List.flatten
			|> Enum.uniq
		
		repo.insert_all(Permission, permissions)
	end

	defp routes do
		Module.concat(Mix.Phoenix.base(), "Router").__routes__
		|> Enum.filter(&Enum.member?(&1.pipe_through, :api))
	end

	def permissions_from_router(router) do
		Enum.map(["all", "self"],
		        &[permission_from_router_with_type(router, &1)])
	end

	def permission_from_router_with_type(router = %Phoenix.Router.Route{}, type)
		when is_binary(type) do
		%{controller_name: Atom.to_string(router.plug),
		controller_action: Atom.to_string(router.opts),
		type: type}
	end
end