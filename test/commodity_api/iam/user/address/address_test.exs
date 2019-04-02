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
defmodule Commodity.Api.Iam.User.AddressTest do
	use Commodity.DataCase

	alias Commodity.Api.Iam.User.Address

	test "changeset with valid params" do
		changeset = Address.changeset(%Address{}, %{user_id: 1, 
			type: "home", name: "Home", country: "Turkey", state: "Atasehir",
			city: "Istanbul", zip_code: "34000", address: "Address"})

		assert changeset.valid?
	end

	test "changeset with invalid params" do
		changeset = Address.changeset(%Address{}, %{user_id: "id", 
			type: "unknown", name: false, country: false, state: false,
			city: false, zip_code: 123.23, address: false})

		refute changeset.valid?
	end

	test "changeset without user_id param" do
		changeset = Address.changeset(%Address{}, %{
			type: "home", name: "Home", country: "Turkey", state: "Atasehir",
			city: "Istanbul", zip_code: "34000", address: "Address"})

		refute changeset.valid?
	end

	test "changeset without type param" do
		changeset = Address.changeset(%Address{}, %{user_id: 1, 
			name: "Home", country: "Turkey", state: "Atasehir",
			city: "Istanbul", zip_code: "34000", address: "Address"})

		refute changeset.valid?
	end

	test "changeset without name param" do
		changeset = Address.changeset(%Address{}, %{user_id: 1, 
			type: "home", country: "Turkey", state: "Atasehir",
			city: "Istanbul", zip_code: "34000", address: "Address"})

		refute changeset.valid?
	end

	test "changeset without country param" do
		changeset = Address.changeset(%Address{}, %{user_id: 1, 
			type: "home", name: "Home", state: "Atasehir",
			city: "Istanbul", zip_code: "34000", address: "Address"})

		refute changeset.valid?
	end

	test "changeset without state param" do
		changeset = Address.changeset(%Address{}, %{user_id: 1, 
			type: "home", name: "Home", country: "Turkey",
			city: "Istanbul", zip_code: "34000", address: "Address"})

		refute changeset.valid?
	end

	test "changeset without city param" do
		changeset = Address.changeset(%Address{}, %{user_id: 1, 
			type: "home", name: "Home", country: "Turkey", state: "Atasehir",
			zip_code: "34000", address: "Address"})

		refute changeset.valid?
	end

	test "changeset without zip_code param" do
		changeset = Address.changeset(%Address{}, %{user_id: 1, 
			type: "home", name: "Home", country: "Turkey", state: "Atasehir",
			city: "Istanbul", address: "Address"})

		refute changeset.valid?
	end

	test "changeset without address param" do
		changeset = Address.changeset(%Address{}, %{user_id: 1, 
			type: "home", name: "Home", country: "Turkey", state: "Atasehir",
			city: "Istanbul", zip_code: "34000"})
		
		refute changeset.valid?
	end
end