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
defmodule Commodity.Api.Iam.User.PassphraseTest do
	use Commodity.DataCase

	alias Commodity.Api.Iam.User.Passphrase
	alias Commodity.Api.Iam.Generic.Passkey

	test "changeset with valid params" do
		changeset = Passphrase.changeset(%Passphrase{},
			%{user_id: 1, passphrase: Passkey.generate()})

		assert changeset.valid?
	end

	test "changeset with invalid params" do
		changeset = Passphrase.changeset(%Passphrase{},
			%{user_id: "id", passphrase: false})

		refute changeset.valid?
	end

	test "changeset without user_id param" do
		changeset = Passphrase.changeset(%Passphrase{},
			%{passphrase: Passkey.generate()})

		refute changeset.valid?
	end

	test "changeset without passphrase param" do
		changeset = Passphrase.changeset(%Passphrase{},
			%{user_id: 1})

		refute changeset.valid?
	end

	test "changeset with invalid passphrase param if max length exceeded" do
		changeset = Passphrase.changeset(%Passphrase{},
			%{user_id: 1, passphrase: "#{Passkey.generate()}fgdfgfgdfg"})

		refute changeset.valid?
	end
end