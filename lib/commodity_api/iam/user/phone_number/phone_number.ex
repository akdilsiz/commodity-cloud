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
defmodule Commodity.Api.Iam.User.PhoneNumber do
	use Commodity.Api, :model

	@derive {Jason.Encoder, only: [:id, :user_id, :value, :type,
		:inserted_at, :updated_at]}
	@phone_number_regex ~r/\w{0,3}\w{3,3}\w{3,3}\w{4}/i
	@timestamps_opts [type: :naive_datetime_usec]

	schema "user_phone_numbers" do
		belongs_to :user, Commodity.Api.Iam.User

		field :value, :string
		field :type, Commodity.Api.Util.Type.Enum.PhoneNumber,
			read_after_writes: true

		timestamps()

		has_one :primary, Commodity.Api.Iam.User.PhoneNumber.Primary,
			foreign_key: :number_id
	end

	def changeset(struct, params \\ %{}) do
		struct
		|> cast(params, [:user_id, :value, :type])
		|> validate_required([:user_id, :value])
		|> validate_format(:value, @phone_number_regex)
		|> validate_length(:value, max: 24)
		|> unique_constraint(:value,
			name: :user_phone_numbers_value_unique)
		|> foreign_key_constraint(:user_id)
	end
end