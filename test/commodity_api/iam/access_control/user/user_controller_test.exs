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
defmodule Commodity.Api.Iam.AccessController.UserControllerTest do
	use Commodity.ConnCase

	alias Commodity.Factory
	# alias Commodity.Elastic

	test "create a user with valid params", %{conn: conn} do
		conn = 
			post conn,
				iam_new_user_path(conn, :create),
				user: %{given_name: "ABDULKADİR",
					family_name: "DİLSİZ", 
					email: "akdilsiz@gmail.com",
					phone_number: "905335107827", 
					gender: "male",
					birthday: "1992-01-10",
					nationality: "TR"}

		data = json_response(conn, 201)

		assert data["time_information"]

		data = data["data"]

		assert data["id"]
		assert data["personal_information"]["id"]
		assert data["personal_information"]["user_id"] == data["id"]
		assert data["personal_information"]["given_name"] == "ABDULKADİR"
		assert data["personal_information"]["family_name"] == "DİLSİZ"
		assert data["personal_information"]["gender"] == "male"
		assert data["personal_information"]["nationality"] == "TR"
		assert data["birthday"] == nil
		assert Enum.at(data["emails"], 0)["id"]
		assert Enum.at(data["emails"], 0)["user_id"] == data["id"]
		assert Enum.at(data["emails"], 0)["value"] == "akdilsiz@gmail.com"
		assert Enum.at(data["emails"], 0)["inserted_at"]
		assert Enum.at(data["phone_numbers"], 0)["id"]
		assert Enum.at(data["phone_numbers"], 0)["user_id"] == data["id"]
		assert Enum.at(data["phone_numbers"], 0)["value"] == "905335107827"
		assert Enum.at(data["phone_numbers"], 0)["type"] == "mobile"
		assert Enum.at(data["phone_numbers"], 0)["inserted_at"]
		assert data["inserted_at"]

		# {:ok, response} = 
		# 	Elastic.get("/user/_doc/" <> to_string(data["id"]))

		# response = response["_source"]

		# assert response["id"] == data["id"]
		# assert response["personal_information"]["user_id"] == data["id"]
		# assert response["personal_information"]["given_name"] == "ABDULKADİR"
		# assert response["personal_information"]["family_name"] == "DİLSİZ"
		# assert response["personal_information"]["birthday"] == "1992-01-10"
		# assert response["personal_information"]["gender"] == "male"
		# assert response["personal_information"]["nationality"] == "TR"	
		# assert response["inserted_at"] == data["inserted_at"]
	end

	test "should be 422 error create a user with invalid params", %{conn: conn} do
		assert_error_sent 422, fn -> 
			post conn,
				iam_new_user_path(conn, :create),
				user: %{given_name: 12.2, email: "upss!!"}
		end
	end

	test "should be 422 error create a user with valid params if
		email adready assigned", %{conn: conn} do
		user = Factory.insert(:user)
		Factory.insert(:user_email,
			user: user, 
			value: "akdilsiz@gmail.com")

		conn = 
			post conn,
				iam_new_user_path(conn, :create),
				user: %{given_name: "Abdulkadir",
					family_name: "DILSIZ", 
					email: "akdilsiz@gmail.com",
					phone_number: "905335107827", 
					gender: "male",
					nationality: "TR"}
		
		assert conn.status == 422

		data = json_response(conn, 422)

		assert data["errors"]["changeset"]["value"] ==
			["has already been taken"] 
	end
end