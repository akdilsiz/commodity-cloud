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
defmodule Commodity.Api.Iam.AccessControl.PermissionTest do
	use Commodity.DataCase

	alias Commodity.Api.Iam.AccessControl.Permission

	@lipsum "Lorem ipsum dolor sit amet, consectetur adipisicing elit,
					sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
					Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris
					nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in
					reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla
					pariatur. Excepteur sint occaecat cupidatat non proident, sunt in
					culpa qui officia deserunt mollit anim id est laborum."

	test "changeset with valid params" do
		changeset = Permission.changeset(%Permission{},
																		%{controller_name: "Elixir.DemoController",
																		controller_action: "create",
																		type: "all"})

		assert changeset.valid?
	end

	test "changeset with invalid params" do
		changeset = Permission.changeset(%Permission{},
																		%{controller_name: 123,
																		controller_action: 123,
																		type: 1254})

		refute changeset.valid?
	end

	test "changeset with controller name param max lenth exceeded" do
		changeset = Permission.changeset(%Permission{},
																		%{controller_name: @lipsum,
																		controller_action: "create",
																		type: "none"})

		refute changeset.valid?
	end

	test "changeset with action param max length exceeded" do
		changeset = Permission.changeset(%Permission{},
																		%{controller_name: "Elixir.DemoController",
																		controller_action: @lipsum,
																		type: "none"})

		refute changeset.valid?
	end
end