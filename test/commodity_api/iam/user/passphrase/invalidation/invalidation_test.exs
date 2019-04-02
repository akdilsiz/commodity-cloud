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
defmodule Commodity.Api.Iam.User.Passphrase.InvalidationTest do
	use Commodity.DataCase

	alias Commodity.Api.Iam.User.Passphrase.Invalidation
	alias Commodity.Factory

	test "changeset with valid params" do
		changeset = Invalidation.changeset(%Invalidation{},
			%{target_passphrase_id: 1, source_passphrase_id: 1})

		assert changeset.valid?
	end

	test "changeset with invalid params" do
		changeset = Invalidation.changeset(%Invalidation{},
			%{target_passphrase_id: "id", source_passphrase_id: "id"})

		refute changeset.valid?
	end

	test "changeset without target_passphrase_id param" do
		changeset = Invalidation.changeset(%Invalidation{},
			%{source_passphrase_id: 1})

		refute changeset.valid?
	end

	test "changeset without source_passphrase_id param" do
		changeset = Invalidation.changeset(%Invalidation{},
			%{target_passphrase_id: 1})

		refute changeset.valid?
	end

	test "changeset with invalid target_passphrase_id param if not unique" do
		passphrase = Factory.insert(:user_passphrase)
		Factory.insert(:user_passphrase_invalidation, target_passphrase: passphrase)

		changeset = Invalidation.changeset(%Invalidation{},
			%{target_passphrase_id: passphrase.id, 
			source_passphrase_id: passphrase.id})

		assert {:error, changeset} = Repo.insert(changeset)
		refute changeset.valid?

		assert ["has already been taken"] == 
			errors_on(changeset).target_passphrase_id
	end
end