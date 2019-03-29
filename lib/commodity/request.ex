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
defmodule Commodity.Request do
  @moduledoc """
  Http Client method for Commodity API
  """

  @spec get(binary, map, binary) :: tuple
  def get(url, headers, body) do
    request(:get, url, headers, body)
  end

  @spec get(binary, map) :: tuple
  def get(url, headers) do
    request(:get, url, headers, [])
  end

  @spec post(binary, map, binary) :: tuple
  def post(url, headers, body) do
    request(:post, url, headers, body)
  end

  @spec put(binary, map, binary) :: tuple
  def put(url, headers, body) do
    request(:put, url, headers, body)
  end

  @spec delete(binary, map, binary) :: tuple
  def delete(url, headers, body) do
    request(:delete, url, headers, body)
  end

  @spec request(atom, binary, map, binary) :: tuple
  defp request(method, url, headers, body) when is_atom(method) do
    case HTTPoison.request(method, url, body, headers, [:ssl]) do
      {:ok, %HTTPoison.Response{body: body, status_code: status_code}} ->
        {:ok, status_code, body}
      {:error, %HTTPoison.Error{id: nil, reason: error}} ->
        {:error, error}
    end
  end
end
