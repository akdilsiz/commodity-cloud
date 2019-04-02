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
defmodule Commodity.Api.Iam.User.PasswordAssignment do
	use Commodity.Api, :model

	import Comeonin.Bcrypt, only: [hashpwsalt: 1]

	schema "user_password_assignments" do
		belongs_to :user, Commodity.Api.Iam.User

		field :password_digest, :string
		field :password, :string, virtual: true

		field :inserted_at, :naive_datetime_usec, read_after_writes: true
	end

	def changeset(struct, params \\ %{}) do
		struct
		|> cast(params, [:user_id, :password])
		|> validate_required([:user_id, :password])
		|> validate_length(:password, min: 8, max: 32)
		|> foreign_key_constraint(:user_id)
		|> hash_password!
	end

	defp hash_password!(changeset) do
		if password = get_change(changeset, :password) do
			put_change(changeset, :password_digest, hashpwsalt(password))
		else
			changeset
		end
	end
end