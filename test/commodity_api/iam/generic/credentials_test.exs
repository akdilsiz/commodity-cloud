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
defmodule Commodity.Api.Iam.Generic.CredentialsTest do
	use Commodity.DataCase

	alias Commodity.Api.Iam.Generic.Credentials

	test "changeset with valid params" do
		changeset = Credentials.changeset(%Credentials{},
			%{email: "akdilsiz@tecpor.com",
				password: "12345678"})

		assert changeset.valid?
	end

	test "changeset with invalid params" do
		changeset = Credentials.changeset(%Credentials{},
			%{email: false,
				password: false})

		refute changeset.valid?
	end

	test "changest without email param" do
		changeset = Credentials.changeset(%Credentials{}, 
			%{password: "12345678"})

		refute changeset.valid?
	end

	test "changeset without password param" do
		changeset = Credentials.changeset(%Credentials{}, 
			%{email: "akdilsiz@gmail.com"})

		refute changeset.valid?
	end
end