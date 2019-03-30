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
defmodule Commodity.Api.Iam.User.EmailTest do
	use Commodity.DataCase

	alias Commodity.Api.Iam.User.Email

	test "changeset with valid params" do
		changeset = Email.changeset(%Email{}, 
			%{user_id: 1, value: "akdilsiz@tecpor.com"})

		assert changeset.valid?
	end

	test "changeset with invalid params" do
		changeset = Email.changeset(%Email{},
			%{user_id: "id", value: false})

		refute changeset.valid?
	end

	test "changeset with invalid email format" do
		changeset = Email.changeset(%Email{}, 
			%{user_id: 1, value: "akdilsiz"})

		refute changeset.valid?
	end

	test "changeset without user_id param" do
		changeset = Email.changeset(%Email{},
			%{value: "akdilsiz@tecpor.com"})

		refute changeset.valid?
	end

	test "changeset without value param" do
		changeset = Email.changeset(%Email{},
			%{user_id: 1})

		refute changeset.valid?
	end

	test "changeset with invalid value param if not unique" do
		Factory.insert(:user_email, value: "akdilsiz@tecpor.com")

		user = Factory.insert(:user)

		changeset = Email.changeset(%Email{}, %{user_id: user.id,
			value: "akdilsiz@tecpor.com"})

		assert {:error, changeset} = Repo.insert(changeset)
		refute changeset.valid?
		assert ["has already been taken"] == errors_on(changeset).value
	end
end