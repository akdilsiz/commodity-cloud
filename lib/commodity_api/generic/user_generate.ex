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
defmodule Commodity.Api.Generic.UserGenerate do
	@moduledoc """
	Module of generate users
	"""
	alias Commodity.Api.Iam.User
	alias Commodity.Api.Iam.User.Passphrase
	alias Commodity.Api.Iam.User.Email
	alias Commodity.Api.Iam.User.PasswordAssignment
	alias Commodity.Api.Iam.Generic.Passkey

	import Comeonin.Bcrypt, only: [hashpwsalt: 1]

	@doc """
	Generatese a test user and user artifacts
	"""
	def generate(repo) do
		user = repo.insert!(%User{})
		repo.insert!(%Passphrase{user_id: user.id,
			passphrase: Passkey.generate()})
		email = repo.insert!(%Email{user_id: user.id,
			value: "superadmin@commodity.tecpor.com"})
		repo.insert!(%Email.Primary{user_id: user.id,
			email_id: email.id, 
			source_user_id: user.id})
		repo.insert!(%PasswordAssignment{user_id: user.id,
			password_digest: hashpwsalt("1234")})

		user = repo.insert!(%User{})
		repo.insert!(%Passphrase{user_id: user.id,
			passphrase: Passkey.generate()})
		email = repo.insert!(%Email{user_id: user.id,
			value: "user@commodity.tecpor.com"})
		repo.insert!(%Email.Primary{user_id: user.id,
			email_id: email.id, 
			source_user_id: user.id})
		repo.insert!(%PasswordAssignment{user_id: user.id,
			password_digest: hashpwsalt("1234")})
	end

	@doc """
	Clean all test users
	"""
	def clean(repo) do
		repo.delete_all(User)
	end

	@doc """
	Generates users after Clean users
	"""
	def clean_and_generate(repo) do
		clean(repo)
		generate(repo)
	end
end