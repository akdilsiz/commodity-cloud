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
defmodule Commodity.Api.Iam.Generic.PasskeyTest do
	use Commodity.DataCase

	alias Commodity.Api.Iam.Generic.Passkey

	test "generate a binary passkey with part param" do
		assert Passkey.bingenerate(4)
	end

	test "generate a binary passkey" do
		assert Passkey.bingenerate
	end

	test "generate a base64 passkey length of 192" do
		passkey = Passkey.generate

		assert passkey
		assert String.length(passkey) == 192
	end

	test "generate a base64 passkey with part param length of 88" do
		passkey = Passkey.generate(4)

		assert passkey
		assert String.length(passkey) == 88
	end

	test "generate a base64 passkey with part param and padding param
		length of 86" do
		passkey = Passkey.generate(4, false)

		assert passkey
		assert String.length(passkey) == 86		
	end

	test "generate a base64 passkey with padding param length of 192" do
		passkey = Passkey.generate(false)

		assert passkey
		assert String.length(passkey) == 192
	end
end