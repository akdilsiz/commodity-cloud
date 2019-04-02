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
defmodule Commodity.Api.Iam.AccessControl.PermissionSetPermissionTest do
	use Commodity.DataCase

	alias Commodity.Api.Iam.AccessControl.PermissionSetPermission

	test "changeset with valid params" do
		changeset = PermissionSetPermission.changeset(%PermissionSetPermission{},
																									%{permission_set_id: 1,
																									permission_id: 1})

		assert changeset.valid?
	end

	test "changeset with invalid params" do
		changeset = PermissionSetPermission.changeset(%PermissionSetPermission{},
																									%{permission_set_id: "sd3",
																									permission_id: "sd4"})

		refute changeset.valid?
	end

	test "changeset without permission set param" do
		changeset = PermissionSetPermission.changeset(%PermissionSetPermission{},
																									%{permission_id: 1})

		refute changeset.valid?
	end

	test "changeset without permission param" do
		changeset = PermissionSetPermission.changeset(%PermissionSetPermission{},
																									%{permission_set_id: 1})

		refute changeset.valid?
	end
end