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
defmodule Mix.Tasks.Commodity.Authentication.Generate do
	@moduledoc """
		Authorization and test users seedind
	"""
	use Mix.Task

	alias Commodity.Repo
	alias Commodity.Api.Generic.UserGenerate
	alias Commodity.Api.Generic.PermissionGenerate
	alias Commodity.Api.Generic.PermissionSetGenerate

	require Logger

	@shortdoc "Generates authentication/authorization artifacts"

	def run(_) do
		Logger.configure(level: :info)

		Logger.configure_backend(:console,
														format: "$time $metadata[$level]" <>
																		" $levelpad$message\n")

		Logger.info "== Running Commodity.Authentication.Generate"

		Mix.Task.run "app.start"

		sandbox? = Repo.config[:pool] == Ecto.Adapters.SQL.Sandbox

		if sandbox? do
			Ecto.Adapters.SQL.Sandbox.checkin(Repo)
			Ecto.Adapters.SQL.Sandbox.checkin(Repo, sandbox: false)
		end

		UserGenerate.clean_and_generate(Repo)
		PermissionGenerate.clean_and_generate(Repo)
		PermissionSetGenerate.clean_and_generate(Repo)

		sandbox? && Ecto.Adapters.SQL.Sandbox.checkin(Repo)

		Logger.info "== Completed Commodity.Authentication.Generate"
	end
end