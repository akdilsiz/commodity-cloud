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
defmodule Commodity.LibraryCase do
	@moduledoc """
	This module defines the test case to be used by
	library tests.

	You may define functions here to be used as helpers in
	your library tests.

	Finally, if the test case interacts with the database,
	it cannot be async. For this reason, every test runs
	inside a transaction which is reset at the beginning
	of the test unless the test case is marked as async.
	"""
	use ExUnit.CaseTemplate

	using do
		quote do
			alias Commodity.Util.Type.String
		end
	end
end