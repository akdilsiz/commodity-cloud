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
defmodule Commodity.Api.Iam.Generic.PassphraseSubmissionTest do
	use Commodity.DataCase

	alias Commodity.Api.Iam.Generic.PassphraseSubmission
	alias Commodity.Api.Iam.Generic.Passkey


	test "changeset with valid params" do
		changeset = PassphraseSubmission.changeset(%PassphraseSubmission{},
			%{passphrase: Passkey.generate()})

		assert changeset.valid?
	end

	test "changest with invalid params" do
		changeset = PassphraseSubmission.changeset(%PassphraseSubmission{},
			%{passphrase: false})

		refute changeset.valid?
	end
end