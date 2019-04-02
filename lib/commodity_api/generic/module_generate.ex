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
defmodule Commodity.Api.Generic.ModuleGenerate do
	@moduledoc """
	Modules generate
	"""
	alias Commodity.Api.Module, as: CModule
	alias Commodity.Api.Util.Route
	alias Rediscl

	def clean_and_generate(repo) do
		clean(repo)
		generate(repo)
	end

	def generate(repo) do
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

		repo.insert_all(Route, routes)

		modules =
			Enum.map(routes, fn x ->
				{x.plug, %{name: x.assigns.name, controller: x.plug}}
			end)
			|> Enum.into(%{})

		modules =
			Enum.map(Map.keys(modules), fn x ->
				%{name: modules[x].name,
					controller: modules[x].controller,
					inserted_at: NaiveDateTime.utc_now,
					updated_at: NaiveDateTime.utc_now}
			end)

		repo.insert_all(CModule, modules)
	end

	def clean(repo) do
	repo.delete_all(CModule)

	repo.delete_all(Route)

	Ecto.Adapters.SQL.query!(repo, "ALTER SEQUENCE modules_id_seq RESTART WITH 1;", [])
	Ecto.Adapters.SQL.query!(repo, "ALTER SEQUENCE routes_id_seq RESTART WITH 1;", [])
	end

	defp routes do
		Module.concat(Mix.Phoenix.base(), "Router").__routes__
		|> Enum.filter(&Enum.member?(&1.pipe_through, :api))
		|> Enum.filter(&(&1.verb != :options))
	end
end
