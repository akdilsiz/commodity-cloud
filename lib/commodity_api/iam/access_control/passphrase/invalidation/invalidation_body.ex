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
defmodule Commodity.Api.Iam.AccessControl.Passphrase.InvalidationBody do
	@moduledoc """
	Invalidation request body
	"""
	use Commodity.Api, :virtual

	embedded_schema do
		field :passphrase_ids, {:array, :integer}
	end

	def changeset(struct, params \\ %{}) do
		struct
		|> cast(params, [:passphrase_ids])
		|> validate_required([:passphrase_ids])
	end
end