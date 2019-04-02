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
defmodule Commodity.Api.Iam.User.Email.LogTest do
	use Commodity.DataCase

	alias Commodity.Api.Iam.User.Email.Log

	test "changeset with valid params" do
		changeset = Log.changeset(%Log{}, %{user_id: 1, email_id: 1, 
			source_user_id: 1})

		assert changeset.valid?
	end

	test "changeset with invalid params" do
		changeset = Log.changeset(%Log{}, %{user_id: "id", email_id: "id",
			source_user_id: "id"})

		refute changeset.valid?
	end

	test "changest without user_id param" do
		changeset = Log.changeset(%Log{}, %{email_id: 1, source_user_id: 1})

		refute changeset.valid?
	end

	test "changeset without email_id param" do
		changeset = Log.changeset(%Log{}, %{user_id: 1, source_user_id: 1})

		refute changeset.valid?
	end

	test "changeset without source_user_id param" do
		changeset = Log.changeset(%Log{}, %{user_id: 1, email_id: 1})

		refute changeset.valid?
	end
end