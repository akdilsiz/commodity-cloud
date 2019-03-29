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
defmodule Commodity.Api.Util.VirtualValidation do
  @moduledoc """
  Module defining set of functions and macros in order to handle virtual
  changesets (forms) in elegant way.
  """

  @doc """
  Validates a virtual form given as a changeset, releases conn if invalid.
  """
  defmacro validate_virtual!(changeset) do
    quote do
      case unquote(changeset).valid? do
        true ->
          unquote(changeset)
        false ->
          raise Commodity.Api.Util.InvalidVirtualChangesetError,
                changeset: unquote(changeset)
      end
    end
  end

  @doc """
  Validates a virtual request given as a changeset, releases conn if invalid.
  """
  defmacro validate_virtual_request!(changeset) do
    quote do
      case unquote(changeset).valid? do
        true ->
          unquote(changeset)
        false ->
          raise Commodity.Api.Util.InvalidVirtualRequestChangesetError,
                changeset: unquote(changeset)
      end
    end
  end
end
