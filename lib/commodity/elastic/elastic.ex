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
defmodule Commodity.Elastic do
  @moduledoc """
  Commodity API Elastic Search Http Client
  """
  alias Commodity.Request
  import Commodity.Elastic.Script, only: [generate: 3]

  @elastic_host Application.get_env(:commodity, :elasticsearch, nil)[:host]
  @elastic_port Application.get_env(:commodity, :elasticsearch, nil)[:port]

  @spec client :: atom
  def client do
    "http://#{@elastic_host}:#{@elastic_port}"
  end

  @doc """
  Get index with query
  """
  def get(uri, query, :decode_keys) when is_map(query) do
    case Request.get(client() <> uri,
                    [{"Content-Type", "application/json"}],
                    Jason.encode!(query)) do
      {:ok, _status, body} ->
        {:ok, Jason.decode!(body, [{:keys, :atoms}])}
      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Get index with query
  """
  def get(uri, query) when is_map(query) do
    case Request.get(client() <> uri,
                    [{"Content-Type", "application/json"}],
                    Jason.encode!(query)) do
      {:ok, _status, body} ->
        {:ok, Jason.decode!(body)}
      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Get index
  """
  def get(uri, :decode_keys) do
    case Request.get(client() <> uri,
                    [{"Content-Type", "application/json"}]) do
      {:ok, _status, body} ->
        {:ok, Jason.decode!(body, [{:keys, :atoms}])}
      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Get index
  """
  def get(uri) do
    case Request.get(client() <> uri,
                    [{"Content-Type", "application/json"}]) do
      {:ok, _status, body} ->
        {:ok, Jason.decode!(body)}
      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Put index query
  """
  def put(uri, query, :query, script) do
    case Request.post(client() <> uri <> "/_update_by_query",
                  [{"Content-Type", "application/json"}],
                  generate(script,
                            query.key,
                            query.value)) do
      {:ok, _status, body} ->
        {:ok, Jason.decode!(body)}
      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Put index when put method
  """
  def put(uri, data, method) when method == :put do
    case Request.put(client() <> uri,
                  [{"Content-Type", "application/json"}],
                  Jason.encode!(data)) do
      {:ok, _status, body} ->
        {:ok, Jason.decode!(body)}
      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Put Bulk index and custom method
  """
  def put(uri, data, method) when is_list(data) do
    case Request.post(client() <> uri,
                  [{"Content-Type", "application/json"}],
                  bulk_data(data, method)) do
      {:ok, _status, body} ->
        {:ok, Jason.decode!(body)}
      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Put Bulk index
  """
  def put(uri, data) when is_list(data) do
    case Request.post(client() <> uri,
                  [{"Content-Type", "application/json"}],
                  bulk_data(data)) do
      {:ok, _status, body} ->
        {:ok, Jason.decode!(body)}
      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Put index
  """
  def put(uri, data) do
    case Request.post(client() <> uri,
                  [{"Content-Type", "application/json"}],
                  Jason.encode!(data)) do
      {:ok, _status, body} ->
        {:ok, Jason.decode!(body)}
      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Delete index
  """
  def delete(uri) do
    case Request.delete(client() <> uri, [], []) do
      {:ok, _status, body} ->
        {:ok, Jason.decode!(body)}
      {:error, error} ->
        {:error, error}
    end
  end

  defp bulk_data(data, method) when is_list(data) do
    Enum.map(data, fn x ->
      case x do
        %{index: index, fields: fields} ->
          index = "{\"#{method}\":" <> Jason.encode!(index) <> "}"
          fields = Jason.encode!(fields)

          index <> "\n" <>
          fields <> "\n"
        %{index: index} ->
          index = "{\"#{method}\":" <> Jason.encode!(index) <> "}"

          index <> "\n"
      end
    end)
    |> List.flatten
    |> Enum.join("")
  end

  defp bulk_data(data) when is_list(data) do
    Enum.map(data, fn x ->
      case x do
        %{index: index, fields: fields} ->
          index = "{\"index\":" <> Jason.encode!(index) <> "}"
          fields = Jason.encode!(fields)

          index <> "\n" <>
          fields <> "\n"
        %{index: index} ->
          index = "{\"#index\":" <> Jason.encode!(index) <> "}"

          index <> "\n"
      end
    end)
    |> List.flatten
    |> Enum.join("")
  end
end
