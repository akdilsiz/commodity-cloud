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
defmodule Commodity.Api.Iam.User.PersonalInformationControllerTest do
	use Commodity.ConnCase

	alias Commodity.Factory

	@moduletag login: :user

	setup %{conn: conn, user: user} do
		permission_set = Repo.get_by!(PermissionSet, name: "Superadmin")
		Factory.insert(:permission_set_grant, user: user, target_user: user,
			permission_set: permission_set)

		%{conn: conn, user: user}
	end

	test "options/1", %{conn: conn} do
		conn = options conn, iam_user_personal_information_path(conn, :create, 1)

		assert conn.status == 204
	end

	test "create a user personal information with given identifier and " <>
		"valid params", %{conn: conn} do
		user = Factory.insert(:user)		

		{:ok, _} =
			Elastic.put("/user/_doc/#{user.id}", 
				%{id: user.id, inserted_at: user.inserted_at})

		conn =
			post conn, iam_user_personal_information_path(conn, :create, user.id),
			personal_information: %{given_name: "Abdulkadir", family_name: "DILSIZ",
				gender: "male", nationality: "TR", birthday: "1992-01-10"}

		data = json_response(conn, 201)

		assert data["time_information"]

		data = data["data"]

		assert data["id"]
		assert data["user_id"] == user.id
		assert data["given_name"] == "Abdulkadir"
		assert data["family_name"] == "DILSIZ"
		assert data["gender"] == "male"
		assert data["nationality"] == "TR"
		assert data["birthday"] == "1992-01-10"
		assert data["inserted_at"]

		assert {:ok, response} =
			Elastic.get("/user/_doc/#{user.id}")

		response = response["_source"]

		assert response["id"] == user.id
		assert response["personal_information"]["given_name"] == "Abdulkadir"
		assert response["personal_information"]["family_name"] == "DILSIZ"
		assert response["personal_information"]["gender"] == "male"
		assert response["personal_information"]["nationality"] == "TR"
		assert response["personal_information"]["birthday"] == "1992-01-10"
	end

	test "should be 422 error create a user personal_information given given " <>
		"identifier and invalid params", %{conn: conn} do
		user = Factory.insert(:user)		

		{:ok, _} =
			Elastic.put("/user/_doc/#{user.id}", 
				%{id: user.id, inserted_at: user.inserted_at})

		conn =
			post conn, iam_user_personal_information_path(conn, :create, user.id),
			personal_information: %{given_name: false, family_name: 12.23,
				gender: false, nationality: "Rize", birthday: "ups"}

		assert conn.status == 422
	end
end 