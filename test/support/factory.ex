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

	import Comeonin.Bcrypt, only: [hashpwsalt: 1]
	alias Commodity.Api.Iam.Generic.Passkey

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

	def user_email_primary_factory do
		%Commodity.Api.Iam.User.Email.Primary{
			email: build(:user_email),
			user: build(:user),
			source_user: build(:user)
		}
	end

	def user_phone_number_factory do
		%Commodity.Api.Iam.User.PhoneNumber{
			user: build(:user),
			value: "905111111111",
			type: "mobile"
		}
	end

	def user_phone_number_log_factory do
		%Commodity.Api.Iam.User.PhoneNumber.Log{
			user: build(:user),
			number: build(:user_phone_number),
			source_user: build(:user)
		}
	end

	def user_phone_number_primary_factory do
		%Commodity.Api.Iam.User.PhoneNumber.Primary{
			number: build(:user_phone_number),
			user: build(:user),
			source_user: build(:user)
		}
	end

	def user_password_assignment_factory do
		%Commodity.Api.Iam.User.PasswordAssignment{
			user: build(:user),
			password_digest: hashpwsalt("12345678")
		}
	end

	def user_passphrase_factory do
		%Commodity.Api.Iam.User.Passphrase{
			user: build(:user),
			passphrase: Passkey.generate()
		}
	end

	def user_passphrase_invalidation_factory do
		%Commodity.Api.Iam.User.Passphrase.Invalidation{
			target_passphrase: build(:user_passphrase),
			source_passphrase: build(:user_passphrase)
		}
	end

	def user_state_factory do
		%Commodity.Api.Iam.User.State{
			user: build(:user),
			source_user: build(:user),
			value: "active",
			note: nil
		}
	end

	def user_address_factory do
		%Commodity.Api.Iam.User.Address{
			user: build(:user),
			type: "home",
			name: sequence(:user_address_name, &"Address #{&1}"),
			country: "Turkey",
			city: "Istanbul",
			state: "Atasehir",
			zip_code: "34212",
			address: "Address"
		}
	end

	def user_address_invalidation_factory do
		%Commodity.Api.Iam.User.Address.Invalidation{
			address: build(:user_address),
			source_user: build(:user)
		}
	end

	def user_address_log_factory do
		%Commodity.Api.Iam.User.Address.Log{
			user: build(:user),
			address: build(:user_address),
			source_user: build(:user)
		}
	end

	def permission_factory do
		%Commodity.Api.Iam.AccessControl.Permission{
			controller_name: sequence(:permission_controller_name,
				&"Elixir.Commodity.#{&1}Controller"),
			controller_action: "index",
			type: "all"
		}
	end

	def permission_set_factory do
		%Commodity.Api.Iam.AccessControl.PermissionSet{
			user: build(:user),
			name: sequence(:permission_set_name, &"Permission #{&1}"),
			description: sequence(:permission_set_description, &"P. Desc #{&1}")
		}
	end

	def permission_set_permission_factory do
		%Commodity.Api.Iam.AccessControl.PermissionSetPermission{
			permission_set: build(:permission_set),
			permission: build(:permission)
		}
	end

	def permission_set_grant_factory do
		%Commodity.Api.Iam.AccessControl.PermissionSetGrant{
			permission_set: build(:permission_set),
			user: build(:user),
			target_user: build(:user)
		}
	end

	def brand_factory do
		%Commodity.Api.Brand{}
	end

	def brand_detail_factory do
		%Commodity.Api.Brand.Detail{
			brand: build(:brand),
			name: sequence(:brand_detail_name, &"Detail #{&1}"),
			slug: sequence(:brand_detail_slug, &"detail-#{&1}"),
			source_user: build(:user)
		}
	end
end