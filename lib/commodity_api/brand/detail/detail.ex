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
defmodule Commodity.Api.Brand.Detail do
	use Commodity.Api, :model

	@derive {Jason.Encoder, only: [:id, :brand_id, :name, :slug,
		:source_user_id, :inserted_at]}

	schema "brand_details" do
		belongs_to :brand, Commodity.Api.Brand
		
		field :name, :string
		field :slug, :string

		belongs_to :source_user, Commodity.Api.Iam.User

		field :inserted_at, :naive_datetime_usec, read_after_writes: true
	end

	def changeset(struct, params \\ %{}) do
		struct 
		|> cast(params, [:brand_id, :name, :slug, :source_user_id])
		|> validate_required([:brand_id, :name, :slug, :source_user_id])
		|> foreign_key_constraint(:brand_id)
		|> foreign_key_constraint(:source_user_id)
		|> to_slug(:slug)
	end
end