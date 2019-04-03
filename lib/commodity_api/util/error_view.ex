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
defmodule Commodity.Api.Util.ErrorView do
  use Commodity.Api, :view

  def render("401.json", _assigns) do
    %{errors: %{name: "Unauthorized", detail: "Authorization is refused due" <>
      " to insufficient privileges."}}
  end

  def render("403.json", assigns) do
    errors =
      if Enum.count(assigns.reason |> Map.from_struct) > 2 do
        fields = assigns.reason |> Map.from_struct
        keys =
          fields |> Map.keys |> Enum.drop(3)

        extra_fields =
          Enum.map(keys, fn x ->
            {x, fields[x]}
          end)
          |> Map.new

        %{name: "Restricted area", detail: assigns.reason.message}
        |> Map.merge(extra_fields)
      else
        %{name: "Restricted area", detail: assigns.reason.message}
      end

    %{errors: errors}
  end

  def render("400.json", assigns) do
    case Map.get(assigns, :reason) do
      :changeset ->
        render Commodity.Api.Util.BadRequestView, "error.json", 
          fields: assigns.reason.changeset
      _ ->
        %{errors: %{name: "Bad request", detail: assigns.reason.message}}
    end
  end

  def render("404.json", _assigns) do
    %{errors: %{name: "Not Found", detail: "We could not find any data on" <>
      " the given parameter."}}
  end

  def render("422.json", assigns) do
    render Commodity.Api.Util.ChangesetView, "error.json", 
      changeset: assigns.reason.changeset
  end

  def render("413.json", assigns) do
    %{errors: %{name: "Quota Error", detail: assigns.reason.message}}
  end

  def render("415.json", assigns) do
    %{errors: %{name: "Unsupported media", detail: assigns.reason.message}}
  end

  def render("500.json", _assigns) do
    %{errors: %{name: "Internal Server Error", detail: "Somethings went" <>
      " wrong in the server, please contact with administrator."}}
  end

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def template_not_found(_template, assigns) do
    render "500.json", assigns
  end
end
