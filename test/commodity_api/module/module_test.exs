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
defmodule Commodity.Api.ModuleTest do
	use Commodity.DataCase

	alias Commodity.Api.Module

	test "changeset with valid params" do
		changeset = Module.changeset(%Module{}, %{name: "Module",
			controller: "ModuleController"})

		assert changeset.valid?
	end

	test "changeset with invalid params" do
		changeset = Module.changeset(%Module{}, %{name: false,
			controller: 1234})

		refute changeset.valid?
	end

	test "changeset without name field" do
		changeset = Module.changeset(%Module{}, %{controller: "ModuleController"})

		refute changeset.valid?
	end

	test "changeset without controller field" do
		changeset = Module.changeset(%Module{}, %{name: "Module"})

		refute changeset.valid?
	end
end