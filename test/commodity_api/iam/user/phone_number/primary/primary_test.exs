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
defmodule Commodity.Api.Iam.User.PhoneNumber.PrimaryTest do
	use Commodity.DataCase

	alias Commodity.Api.Iam.User.PhoneNumber.Primary

	test "changeset with valid params" do
		changeset = Primary.changeset(%Primary{},
			%{number_id: 1, user_id: 1, source_user_id: 1})

		assert changeset.valid?
	end

	test "changeset with invalid params" do
		changeset = Primary.changeset(%Primary{},
			%{number_id: "id", user_id: "1", source_user_id: "id"})

		refute changeset.valid?
	end

	test "changeset without number_id param" do
		changeset = Primary.changeset(%Primary{},
			%{user_id: 1, source_user_id: 1})

		refute changeset.valid?
	end

	test "changeset without user_id param" do
		changeset = Primary.changeset(%Primary{},
			%{number_id: 1, source_user_id: 1})

		refute changeset.valid?
	end

	test "changeset without source_user_id param" do
		changeset = Primary.changeset(%Primary{},
			%{number_id: 1, user_id: 1})

		refute changeset.valid?
	end

	test "changest with invalid number_id if not unique" do
		number = Factory.insert(:user_phone_number, value: "akdilsiz@tecpor.com")
		Factory.insert(:user_phone_number_primary, number: number, user: number.user)

		changeset = Primary.changeset(%Primary{},
			%{number_id: number.id, user_id: number.user.id, 
			source_user_id: number.user.id})

		assert {:error, changeset} = Repo.insert(changeset)
		refute changeset.valid?
		assert ["has already been taken"] == errors_on(changeset).number_id
	end
end