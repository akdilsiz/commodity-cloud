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
defmodule Commodity.Api.Brand.DetailTest do
	use Commodity.DataCase

	alias Commodity.Api.Brand.Detail

	test "changeset with valid params" do
		changeset = Detail.changeset(%Detail{}, %{brand_id: 1, name: "Brand",
			slug: "brand", source_user_id: 1})

		assert changeset.valid?
	end

	test "changeset with invalid params" do
		changeset = Detail.changeset(%Detail{}, %{brand_id: "id", name: false,
			slug: 123.23, source_user_id: "id"})

		refute changeset.valid?
	end

	test "changeset without brand_id param" do
		changeset = Detail.changeset(%Detail{}, %{name: "Brand",
			slug: "brand", source_user_id: 1})

		refute changeset.valid?
	end

	test "changeset without name param" do
		changeset = Detail.changeset(%Detail{}, %{brand_id: 1, slug: "brand",
			source_user_id: 1})

		refute changeset.valid?
	end

	test "changeset without slug param" do
		changeset = Detail.changeset(%Detail{}, %{name: "Brand",
			source_user_id: 1})

		refute changeset.valid?
	end

	test "changeset without source_user_id param" do
		changeset = Detail.changeset(%Detail{}, %{name: "Brand",
			slug: "brand"})

		refute changeset.valid?
	end
end