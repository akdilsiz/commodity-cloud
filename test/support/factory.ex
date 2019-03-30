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
defmodule Commodity.Factory do
	@moduledoc """
	Generates data for tests.
	"""
	use ExMachina.Ecto, repo: Commodity.Repo

	def user_factory do
		%Commodity.Api.Iam.User{}
	end

	def user_personal_information_factory do
		%Commodity.Api.Iam.User.PersonalInformation{
			user: build(:user),
			source_user: build(:user),
			given_name: sequence(:user_personal_information_given_name,
				&"Given name #{&1}"),
			family_name: sequence(:user_personal_information_family_name,
				&"Family name #{&1}"),
			gender: "not_specified",
			nationality: "TR",
			birthday: nil
		}
	end

	def user_email_factory do
		%Commodity.Api.Iam.User.Email{
			user: build(:user),
			value: sequence(:user_email_value, &"email#{&1}@mail.com")
		}
	end

	def user_email_log_factory do
		%Commodity.Api.Iam.User.Email.Log{
			user: build(:user),
			email: build(:user_email),
			source_user: build(:user)
		}
	end
end