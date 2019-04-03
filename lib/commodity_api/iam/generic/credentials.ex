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
defmodule Commodity.Api.Iam.Generic.Credentials do
	@moduledoc """
	Authentication provides users for create access token required
  credentials
	"""
	use Commodity.Api, :virtual
	@email_regex ~r/\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i

	@primary_key false
	embedded_schema do
		field :email, :string
		field :password, :string
	end

	def changeset(struct, params \\ %{}) do
		struct
		|> cast(params, [:email, :password])
		|> validate_required([:email, :password])
		|> validate_format(:email, @email_regex)
	end
end