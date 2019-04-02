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
defmodule Commodity.Api.Iam.User.Passphrase.Invalidation do
	use Commodity.Api, :model

	@primary_key {:target_passphrase_id, :id, autogenerate: false}
	schema "user_passphrase_invalidations" do
		belongs_to :target_passphrase, Commodity.Api.Iam.User.Passphrase,
			define_field: false,
			primary_key: true
		belongs_to :source_passphrase, Commodity.Api.Iam.User.Passphrase

		field :inserted_at, :naive_datetime_usec, read_after_writes: true
	end

	def changeset(struct, params \\ %{}) do
		struct
		|> cast(params, [:target_passphrase_id, :source_passphrase_id])
		|> validate_required([:target_passphrase_id, :source_passphrase_id])
		|> unique_constraint(:target_passphrase_id,
			name: :user_passphrase_invalidations_pkey)
		|> foreign_key_constraint(:target_passphrase_id)
		|> foreign_key_constraint(:source_passphrase_id)
	end
end