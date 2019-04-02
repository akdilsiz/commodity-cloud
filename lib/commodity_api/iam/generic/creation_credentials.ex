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
defmodule Commodity.Api.Iam.Generic.CreationCredentials do
	@moduledoc """
	Creation credentials for user
	"""
	use Commodity.Api, :virtual
	
	@email_regex ~r/\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
	@phone_number_regex ~r/\w{0,3}\w{3,3}\w{3,3}\w{4}/i

	@primary_key false
	embedded_schema do
		field :given_name, :string
		field :family_name, :string
		field :email, :string
		field :phone_number, :string
		field :gender, Commodity.Api.Util.Type.Enum.Gender,
			default: "not_specified"
		field :nationality, Commodity.Api.Util.Type.Enum.Nationality
		field :birthday, :date
	end

	def changeset(struct, params \\ %{}) do
		struct
		|> cast(params, [:given_name, :family_name, :email,
			:phone_number, :gender, :nationality, :birthday])
		|> validate_required([:given_name, :family_name, :email, :phone_number,
			:gender, :nationality])
		|> validate_format(:email, @email_regex)
		|> validate_format(:phone_number, @phone_number_regex)
	end
end