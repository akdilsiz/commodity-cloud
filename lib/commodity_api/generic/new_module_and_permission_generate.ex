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
defmodule Commodity.Api.Generic.NewModuleAndPermissionGenerate do
	@moduledoc """
	Permissions and module assignments generate of added new module 
	"""
	alias Commodity.Api.Module, as: BiModule
	alias Commodity.Api.Iam.AccessControl.Permission
	alias Commodity.Api.Iam.AccessControl.PermissionSet
	alias Commodity.Api.Iam.AccessControl.PermissionSetPermission

	@redis_keys Application.get_env(:commodity, :redis_keys)

	def clean_and_generate(repo) do
		clean(repo)
		generate(repo)
	end

	def generate(repo) do
		repo.transaction(fn -> 
			current_modules = repo.all(BiModule)

			current_module_controllers = 
				Enum.map(current_modules, 
								&%{name: &1.name, controller: &1.controller})

			routes =
				Enum.map(routes(), fn x ->
					%{assigns: x.assigns,
					helper: x.helper,
					host: x.host,
					kind: Atom.to_string(x.kind),
					opts: Atom.to_string(x.opts),
					path: x.path,
					pipe_through: Enum.map(x.pipe_through, fn x -> Atom.to_string(x) end),
					plug: Atom.to_string(x.plug),
					private: x.private,
					verb: Atom.to_string(x.verb)}
				end)

			new_modules =
				Enum.map(routes, fn x ->
					{x.plug, %{name: x.assigns[:name], controller: x.plug}}
				end)
				|> Enum.into(%{})

			new_modules =
				Enum.map(Map.keys(new_modules), fn x ->
					%{name: new_modules[x].name,
					controller: new_modules[x].controller}
				end)

			new_modules = new_modules -- current_module_controllers

			_modules =
				Enum.map(new_modules, fn x ->
					%BiModule{name: x.name, controller: x.controller}
					|> repo.insert!
				end)

			routes = Enum.filter(routes, fn x ->
				Enum.any?(new_modules, fn y -> 
					x.plug == y.controller
				end)
			end)
			|> Enum.map(&struct(Phoenix.Router.Route, &1))

			{:ok, keys} =
				Rediscl.Query.command("KEYS", "#{@redis_keys[:permission].cache}*")

			if Enum.count(keys) > 0 do
				{:ok, _} =
					Rediscl.Query.del(keys)	
			end
			
			routes
			|> Enum.map(&permissions_from_router/1)
			|> List.flatten
			|> Enum.uniq
			|> Enum.map(&repo.insert!(&1))
			|> permission_set_permissions(repo)
		end, timeout: :infinity)
	end

	def clean(_) do
		:ok
	end

	defp routes do
		Module.concat(Mix.Phoenix.base(), "Router").__routes__
		|> Enum.filter(&Enum.member?(&1.pipe_through, :api))
		|> Enum.filter(&(&1.opts != :options))
	end

	def permissions_from_router(router) do
		Enum.map(["all", "self"],
						&[permission_from_router_with_type(router, &1)])
	end

	def permission_from_router_with_type(router = %Phoenix.Router.Route{}, type)
		when is_binary(type) do
		%Permission{controller_name: router.plug,
								controller_action: router.opts,
								type: type}
	end

	def permission_set_permissions(permissions, repo) do
		superadmin_permission_set = repo.get_by!(PermissionSet, name: "Superadmin")
		self_permission_set = repo.get_by!(PermissionSet, name: "Self")

		superadmin_permissions = 
			Enum.filter(permissions, &(&1.type == "superadmin"))

		superadmin_permission_set_permissions =
    	Enum.map(superadmin_permissions, &%{permission_set_id: superadmin_permission_set.id,
    														permission_id: &1.id})

  	repo.insert_all(PermissionSetPermission, superadmin_permission_set_permissions)

  	self_permissions = 
  		Enum.filter(permissions, &(&1.type == "self"))
  	self_permission_set_permissions =
    	Enum.map(self_permissions, &%{permission_set_id: self_permission_set.id,
    														permission_id: &1.id})

  	repo.insert_all(PermissionSetPermission, self_permission_set_permissions)

  	Enum.map(permissions, &(&1.id))
	end
end