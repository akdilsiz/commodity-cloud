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
defmodule Commodity.Api.Iam.User.PersonalInformationTest do
	use Commodity.DataCase

	@lipsum "Lorem ipsum dolor sit amet, consectetur adipiscing elit volutpat."

	alias Commodity.Api.Iam.User.PersonalInformation

	test "changeset with valid params" do
		changeset = PersonalInformation.changeset(%PersonalInformation{},
			%{user_id: 1, given_name: "Abdulkadir", family_name: "DILSIZ", 
			gender: "male", nationality: "TR", birthday: "1992-01-10",
			source_user_id: 1})

		assert changeset.valid?
	end

	test "changeset with invalid params" do
		changeset = PersonalInformation.changeset(%PersonalInformation{},
			%{user_id: "id", given_name: false, family_name: false, gender: "unknown", 
			nationality: false, birthday: false, source_user_id: false})

		refute changeset.valid?
	end

	test "changeset without user_id param" do
		changeset = PersonalInformation.changeset(%PersonalInformation{},
			%{given_name: "Abdulkadir", family_name: "DILSIZ", source_user_id: 1})

		refute changeset.valid?
	end

	test "changeset without given_name param" do
		changeset = PersonalInformation.changeset(%PersonalInformation{},
			%{user_id: 1, family_name: "DILSIZ", source_user_id: 1})

		refute changeset.valid?
	end

	test "changeset without family_name param" do
		changeset = PersonalInformation.changeset(%PersonalInformation{},
			%{user_id: 1, given_name: "Abdulkadir", source_user_id: 1})

		refute changeset.valid?
	end

	test "changeset with invalid given_name param if min length exceeded" do
		changeset = PersonalInformation.changeset(%PersonalInformation{},
			%{user_id: 1, given_name: "Ab", family_name: "DILSIZ", source_user_id: 1})

		refute changeset.valid?
	end

	test "changeset with invalid given_name param if max length exceeded" do
		changeset = PersonalInformation.changeset(%PersonalInformation{},
			%{user_id: 1, given_name: @lipsum, family_name: "DILSIZ"})

		refute changeset.valid?
	end

	test "changeset with invalid family_name param if min length exceeded" do
		changeset = PersonalInformation.changeset(%PersonalInformation{},
			%{user_id: 1, given_name: "Abdulkadir", family_name: "DI",
			source_user_id: 1})

		refute changeset.valid?
	end

	test "changeset with invalid family_name param if max length exceeded" do
		changeset = PersonalInformation.changeset(%PersonalInformation{},
			%{user_id: 1, given_name: "Abdulkadir", family_name: @lipsum,
			source_user_id: 1})

		refute changeset.valid?
	end

	test "changeset without  source_user_id param" do
		changeset = PersonalInformation.changeset(%PersonalInformation{},
			%{user_id: 1, given_name: "Abdulkadir", family_name: "DILSIZ"})

		refute changeset.valid?
	end
end