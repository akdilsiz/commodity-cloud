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
defmodule Commodity.Api.Iam.PhoneNumberTest do
	use Commodity.DataCase

	alias Commodity.Api.Iam.User.PhoneNumber

	test "changeset with valid params" do
		changeset = PhoneNumber.changeset(%PhoneNumber{},
			%{user_id: 1, value: "905111111111", type: "mobile"})

		assert changeset.valid?
	end

	test "changeset with invalid params" do
		changeset = PhoneNumber.changeset(%PhoneNumber{},
			%{user_id: "id", value: false, type: "unknown"})

		refute changeset.valid?
	end

	test "changest without user_id param" do
		changeset = PhoneNumber.changeset(%PhoneNumber{},
			%{value: "905111111111", type: "mobile"})

		refute changeset.valid?
	end

	test "changeset without value param" do
		changeset = PhoneNumber.changeset(%PhoneNumber{},
			%{user_id: 1, type: "mobile"})

		refute changeset.valid?
	end

	test "changeset with invalid value param" do
		changeset = PhoneNumber.changeset(%PhoneNumber{},
			%{user_id: 1, value: "111", type: "home"})

		refute changeset.valid?
	end

	test "changeset with invalid value param if not unique" do
		phone_number = Factory.insert(:user_phone_number, 
			value: "905111111111")

		changeset = PhoneNumber.changeset(%PhoneNumber{},
			%{user_id: 1, value: "905111111111", type: "mobile"})

		assert {:error, changeset} = Repo.insert(changeset)
		refute changeset.valid?
		assert ["has already been taken"] == errors_on(changeset).value
	end
end