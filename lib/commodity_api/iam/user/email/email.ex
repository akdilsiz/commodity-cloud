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
defmodule Commodity.Api.Iam.User.Email do
	use Commodity.Api, :model

	@derive {Jason.Encoder, only: [:id, :user_id, :value, :inserted_at,
		:updated_at]}

	@timestamps_opts [type: :naive_datetime_usec]
	@email_regex ~r/\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i

	schema "user_emails" do
		belongs_to :user, Commodity.Api.Iam.User

		field :value, :string

		timestamps()

		has_one :primary, Commodity.Api.Iam.User.Email.Primary,
			foreign_key: :email_id
	end

	def changeset(struct, params \\ %{}) do
		struct
		|> cast(params, [:user_id, :value])
		|> validate_required([:user_id, :value])
		|> validate_format(:value, @email_regex)
		|> validate_length(:value, min: 5, max: 64)
		|> unique_constraint(:value, name: :user_emails_value_unique)
		|> foreign_key_constraint(:user_id)
	end
end