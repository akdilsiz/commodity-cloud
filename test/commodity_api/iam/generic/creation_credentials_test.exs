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
defmodule Commodity.Api.Iam.Generic.CreationCredentialsTest do
	use Commodity.DataCase

	alias Commodity.Api.Iam.Generic.CreationCredentials

	test "changeset with valid params" do
		changeset = 
			CreationCredentials.changeset(%CreationCredentials{},
				%{given_name: "Abdulkadir",
					family_name: "DILSIZ",
					email: "akdilsiz@tecpor.com",
					phone_number: "05111111111",
					gender: "male",
					nationality: "TR",
					birthday: "1992-01-10"})

		assert changeset.valid?
	end

	test "changeset with invalid params" do
		changeset =
			CreationCredentials.changeset(%CreationCredentials{},
				%{given_name: 1234,
					family_name: 1234,
					email: "1234",
					phone_number: false,
					nationality: "unknown",
					birthday: "1992"})

		refute changeset.valid?
	end
end