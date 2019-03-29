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
defmodule Commodity.Api.Util.Type.Mime do
  @moduledoc """
  Allowed mime type of Commodity Backend API
  """
  use Commodity.Api, :library

  @spec allowed_mime_types(atom) :: list
  def allowed_mime_types(type) when type == :image do
    MIME.extensions("image/gif") ++
    MIME.extensions("image/x-icon") ++
    MIME.extensions("image/png") ++
    MIME.extensions("image/webp") ++
    MIME.extensions("image/tiff") ++
    MIME.extensions("image/jpeg")
  end

  @spec allowed_mime_types() :: list
  def allowed_mime_types do
    mime_type =
      MIME.extensions("audio/mp4") ++
      MIME.extensions("video/mp4") ++
      MIME.extensions("video/3gpp") ++
      MIME.extensions("video/quicktime") ++
      MIME.extensions("video/3gpp2") ++
      MIME.extensions("video/3gpp-tt") ++
      MIME.extensions("video/x-msvideo") ++
      MIME.extensions("application/msword") ++
      MIME.extensions("image/gif") ++
      MIME.extensions("image/x-icon") ++
      MIME.extensions("text/calendar") ++
      MIME.extensions("image/jpeg") ++
      MIME.extensions("audio/midi") ++
      MIME.extensions("video/mpeg") ++
      MIME.extensions("application/vnd.oasis.opendocument.presentation") ++
      MIME.extensions("application/vnd.oasis.opendocument.spreadsheet") ++
      MIME.extensions("application/vnd.oasis.opendocument.text") ++
      MIME.extensions("audio/ogg") ++
      MIME.extensions("video/ogg") ++
      MIME.extensions("image/png") ++
      MIME.extensions("application/pdf") ++
      MIME.extensions("application/vnd.ms-powerpoint") ++
      MIME.extensions("application/x-rar-compressed") ++
      MIME.extensions("image/webp") ++
      MIME.extensions("video/webm") ++
      MIME.extensions("audio/webm") ++
      MIME.extensions("audio/x-wav") ++
      MIME.extensions("image/tiff") ++
      MIME.extensions("application/vnd.ms-excel") ++
      MIME.extensions("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet") ++
      MIME.extensions("application/zip") ++
      MIME.extensions("text/html") ++
      ["web"]
      |> List.flatten
      |> Enum.map(&String.to_atom(&1))

    mime_type
  end

  @spec get_type(binary) :: binary | list
  def get_type(file) do
    case MIME.from_path(file) do
      "application/octet-stream" ->
        file =
          if String.last(file) != "/",
            do: file <> "/",
            else: file

        case URI.parse(file) do
          %URI{scheme: nil} ->
            {:error, :invalid_type}
          %URI{host: nil} ->
            {:error, :invalid_type}
          %URI{path: nil} ->
            {:error, :invalid_type}
          uri ->
            {:ok, uri}
        end
      type ->
        {:ok, String.split(type, "/") |> List.last}
    end
  end
end
