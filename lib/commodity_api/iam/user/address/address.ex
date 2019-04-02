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
defmodule Commodity.Api.Iam.User.Address do
	use Commodity.Api, :model

	@derive {Jason.Encoder, only: [:id, :user_id, :type, :name, :country,
		:state, :city, :zip_code, :address, :inserted_at, :updated_at]}
	@timestamps_opts [type: :naive_datetime_usec]

	schema "user_addresses" do
		belongs_to :user, Commodity.Api.Iam.User

		field :type, Commodity.Api.Util.Type.Enum.Address,
			read_after_writes: true
		field :name, :string
		field :country, :string
		field :state, :string
		field :city, :string
		field :zip_code, :string
		field :address, :string

		timestamps()
	end

	def changeset(struct, params \\ %{}) do
		struct
		|> cast(params, [:user_id, :type, :name, :country, :state, :city,
				:zip_code, :address])
		|> validate_required([:user_id, :type, :name, :country, :state, :city,
				:zip_code, :address])
		|> validate_length(:name, max: 64)
		|> validate_length(:country, max: 24)
		|> validate_length(:state, max: 32)
		|> validate_length(:city, max: 32)
		|> validate_length(:address, max: 512)
		|> foreign_key_constraint(:user_id)
		|> to_capitalize(:city)
		|> to_capitalize(:country)
		|> to_capitalize(:state)
		|> to_capitalize(:name)
	end

	defp to_capitalize(changeset, field) do
		if cap_field = get_change(changeset, field) do
			put_change(changeset, field, String.capitalize(cap_field))
		else
			changeset
		end
	end
end