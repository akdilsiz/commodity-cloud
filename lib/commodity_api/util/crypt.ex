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
defmodule Commodity.Api.Util.Crypt do
  @doc """
  Create an HMAC-SHA256 for `key` and `message`.
  """
  def hmac_sha256(key, message) do
    :crypto.hmac(:sha256, key, message)
  end

  @doc """
  Create an HMAC-SHA256 hexdigest for `key` and `message`.
  """
  def hmac_sha256_hexdigest(key, message) do
    hmac_sha256(key, message) |> Base.encode16(case: :lower)
  end

  @doc """
  Create a SHA256 hexdigest for `value`.
  """
  def sha256_hexdigest(value) do
    :crypto.hash(:sha256, value) |> Base.encode16(case: :lower)
  end
end
