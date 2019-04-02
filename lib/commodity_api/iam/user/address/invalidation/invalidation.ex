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
defmodule Commodity.Api.Iam.User.Address.Invalidation do
	use Commodity.Api, :model

	@primary_key {:address_id, :id, autogenerate: false}
	schema "user_address_invalidations" do
		belongs_to :address, Commodity.Api.Iam.User.Address,
			define_field: false,
			primary_key: true
		belongs_to :source_user, Commodity.Api.Iam.User

		field :inserted_at, :naive_datetime_usec, read_after_writes: true
	end

	def changeset(struct, params \\ %{}) do
		struct
		|> cast(params, [:address_id, :source_user_id])
		|> validate_required([:address_id, :source_user_id])
		|> unique_constraint(:address_id,
			name: :user_address_invalidations_pkey)
		|> foreign_key_constraint(:address_id)
		|> foreign_key_constraint(:source_user_id)
	end
end