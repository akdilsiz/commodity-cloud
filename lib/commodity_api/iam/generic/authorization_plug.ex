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
defmodule Commodity.Api.Iam.Generic.AuthorizationPlug do
	@moduledoc """
  Modules a authorization plug
  """
	use Commodity.Api, :plug

	alias Commodity.Api.Iam.AccessControl.Permission
	alias Commodity.Api.Iam.AccessControl.PermissionSet
	alias Commodity.Api.Iam.AccessControl.PermissionSetGrant
	alias Commodity.Api.Iam.AccessControl.PermissionSetPermission
	alias Commodity.Repo

	@spec authorized(Plug.Conn.t, Keyword.t) ::
		Plug.Conn.t
	def authorized(conn, available_types) do
		controller_name = Atom.to_string conn.private.phoenix_controller
		controller_action = Atom.to_string conn.private.phoenix_action

		if controller_action == "options" do
			conn
		else
			available_types = Enum.map(available_types, &Atom.to_string/1)
			available_types_s = List.to_string(available_types)

			{permission_id, permission_type, permission_set_permission_id} =
				case Rediscl.Query.get("#{@redis_keys[:permission].cache}" <>
					":#{controller_name}:#{controller_action}:" <>
					available_types_s <>
					":#{conn.assigns[:user_id]}") do
					{:ok, :undefined} ->
						query = from psg in PermissionSetGrant,
										left_join: psg2 in PermissionSetGrant,
											on: psg.target_user_id == psg2.target_user_id and
													psg.id < psg2.id,
										join: psp in PermissionSetPermission,
											on: psp.permission_set_id == psg.permission_set_id,
										join: ps in PermissionSet,
											on: ps.id == psp.permission_set_id,
										join: p in Permission,
											on: p.id == psp.permission_id,
										where: is_nil(psg2.id) and 
														psg.target_user_id == ^conn.assigns[:user_id] and
														p.controller_name == ^controller_name and
														p.controller_action == ^controller_action and
														p.type in ^available_types,
										order_by: [asc: p.id],
										select: {p.id, p.type, psp.id},
										limit: 1

							case Repo.one(query) do
								nil ->
									{nil, nil, nil}
								{permission_id, permission_type, permission_set_permission_id} ->
									Rediscl.Query.set_ex("#{@redis_keys[:permission].cache}" <>
										":#{controller_name}:#{controller_action}:" <>
										available_types_s <>
										":#{conn.assigns[:user_id]}", 1800, 
										Jason.encode!(%{permission_id: permission_id, 
											permission_type: permission_type,
											permission_set_permission_id: permission_set_permission_id}))

									{permission_id, permission_type, permission_set_permission_id}
							end
					{:ok, cached_permissions} ->
						cached_permissions =
							Jason.decode!(cached_permissions, [{:keys, :atoms!}])

						permission_id = cached_permissions.permission_id
						permission_type = cached_permissions.permission_type
						permission_set_permission_id =
							cached_permissions.permission_set_permission_id

						if permission_type in available_types do
							{permission_id, permission_type, permission_set_permission_id}
						else
							{nil, nil, nil}
						end
				end

			if is_nil(permission_id) and is_nil(permission_type) and
				is_nil(permission_set_permission_id) do
				conn
				|> put_status(403)
				|> Phoenix.Controller.put_view(Commodity.Api.Util.PermissionNotFoundView)
				|> Phoenix.Controller.render("permission_not_found.json", %{})
				|> halt
			else
				conn
				|> assign(:permission_type, String.to_atom(permission_type))
				|> assign(:permission_id, permission_id)
				|> assign(:permission_set_permission_id, 
							permission_set_permission_id)
				|> assign(:permission_method, controller_action)
			end
		end
	end

	@spec apply_policy(Plug.Conn.t, Keyword.t) ::
		Plug.Conn.t
	def apply_policy(conn, params) do
		policy_module = Keyword.get(params, :module, fetch_policy_module(conn))
		
		if conn.private.phoenix_action == :options do
			conn
		else
			case conn.assigns[:permission_type] do
				:all ->
					conn
				_ ->
					if Kernel.apply(policy_module,
					       conn.private.phoenix_action,
					       [conn, conn.params, conn.assigns[:permission_type]]) do
						conn
					else
						conn
						|> put_status(403)
						|> send_resp(403, "Unauthorized")
						|> halt
					end
			end
		end
	end

	@spec fetch_policy_module(Plug.Conn.t) ::
		atom
	defp fetch_policy_module(conn) do
		conn.private.phoenix_controller
		|> Atom.to_string
		|> String.split("Controller")
		|> Enum.at(0)
		|> Kernel.<>("Policy")
		|> String.to_atom
	end
end