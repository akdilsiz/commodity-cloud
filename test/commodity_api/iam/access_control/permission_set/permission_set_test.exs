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
defmodule Commodity.Api.Iam.AccessControl.PermissionSetTest do
	use Commodity.DataCase

	alias Commodity.Api.Iam.AccessControl.PermissionSet
	alias Commodity.Factory

	test "changeset with permission valid params" do
		permission = Factory.insert(:permission)

		changeset =
			PermissionSet.changeset(%PermissionSet{},
															%{name: "Permission Set 1",
															description: "Permission Set 1 Description",
															user_id: 1,
															permission_ids: [permission.id]})

		assert changeset.valid? 
		assert get_field(changeset, :permissions) == [permission]
	end

	test "changeset with invalid permission params" do
		changeset =
			PermissionSet.changeset(%PermissionSet{},
															%{name: "Permission Set 2",
															description: "Permission Set 2 Desctiption",
															user_id: 1,
															permission_ids: [-123]})

		refute changeset.valid?
	end

	test "changeset without permission param" do
		changeset =
			PermissionSet.changeset(%PermissionSet{},
															%{name: "Permission Set 2",
															description: "Permission Set 2 Desctiption",
															user_id: 1,
															permission_ids: nil})

		refute changeset.valid?
	end

	test "changeset with notparse permission param array" do
		permission = Factory.insert(:permission)

		changeset =
			PermissionSet.changeset(%PermissionSet{},
															%{name: "Permission Set 2",
															description: "Permission Set 2 Description",
															user_id: 1,
															permission_ids: [permission.id, permission.id]})

		refute changeset.valid?
	end
end