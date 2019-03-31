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
defmodule Commodity.Api.Iam.User.PhoneNumber.Log do
	use Commodity.Api, :model

	@derive {Jason.Encoder, only: [:id, :user_id, :number_id, :source_user_id,
		:inserted_at]}

	schema "user_email_logs" do
		belongs_to :user, Commodity.Api.Iam.User
		belongs_to :number, Commodity.Api.Iam.User.PhoneNumber
		belongs_to :source_user, Commodity.Api.Iam.User

		field :inserted_at, :naive_datetime_usec, read_after_writes: true
	end

	def changeset(struct, params \\ %{}) do
		struct
		|> cast(params, [:user_id, :number_id, :source_user_id])
		|> validate_required([:user_id, :number_id, :source_user_id])
		|> foreign_key_constraint(:user_id)
		|> foreign_key_constraint(:number_id)
		|> foreign_key_constraint(:source_user_id)
	end
end