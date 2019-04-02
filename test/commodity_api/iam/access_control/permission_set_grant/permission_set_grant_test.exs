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
defmodule Commodity.Api.Iam.AccessControl.PermissionSetGrantTest do
	use Commodity.DataCase

	alias Commodity.Api.Iam.AccessControl.PermissionSetGrant

	test "changeset with valid params" do
		changeset = PermissionSetGrant.changeset(%PermissionSetGrant{},
																						%{permission_set_id: 1,
																						user_id: 1,
																						target_user_id: 1})

		assert changeset.valid?
	end

	test "changeset with invalidp params" do
		changeset = PermissionSetGrant.changeset(%PermissionSetGrant{},
																						%{permission_set_id: "123s",
																						user_id: "sa3",
																						target_user_id: "dsf3"})

		refute changeset.valid?
	end

	test "changeset without permission set param" do
		changeset = PermissionSetGrant.changeset(%PermissionSetGrant{},
																							%{user_id: 1,
																							target_user_id: 1})

		refute changeset.valid?
	end

	test "changeset without user param" do
		changeset = PermissionSetGrant.changeset(%PermissionSetGrant{},
																						%{permission_set_id: 1,
																						target_user_id: 1})

		refute changeset.valid?
	end

	test "changeset without target user param" do
		changeset = PermissionSetGrant.changeset(%PermissionSetGrant{},
																						%{permission_set_id: 1,
																						user_id: 1})

		refute changeset.valid?
	end
end