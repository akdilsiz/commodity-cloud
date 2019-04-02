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
defmodule Commodity.Api.Iam.User.Address.InvalidationTest do
	use Commodity.DataCase

	alias Commodity.Api.Iam.User.Address.Invalidation
	alias Commodity.Factory

	test "changeset with valid params" do
		changeset = Invalidation.changeset(%Invalidation{},
			%{address_id: 1, source_user_id: 1})

		assert changeset.valid?
	end

	test "changeset with invalid params" do
		changeset = Invalidation.changeset(%Invalidation{},
			%{address_id: "id", source_user_id: "id"})

		refute changeset.valid?
	end

	test "changeset without address_id param" do
		changeset = Invalidation.changeset(%Invalidation{},
			%{source_user_id: 1})

		refute changeset.valid?
	end

	test "changeset without source_user_id param" do
		changeset = Invalidation.changeset(%Invalidation{},
			%{address_id: 1})

		refute changeset.valid?
	end

	test "changeset with invalid address_id param if not unique" do
		address = Factory.insert(:user_address)
		Factory.insert(:user_address_invalidation, address: address)

		changeset = Invalidation.changeset(%Invalidation{},
			%{address_id: address.id, source_user_id: address.user.id})

		assert {:error, changeset} = Repo.insert(changeset)
		refute changeset.valid?

		assert ["has already been taken"] == errors_on(changeset).address_id
	end
end