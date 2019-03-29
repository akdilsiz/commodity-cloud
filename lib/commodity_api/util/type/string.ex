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
defmodule Commodity.Api.Util.Type.String do
  @moduledoc """
  Module defines of Commodity string
  """

  import Ecto.Changeset, only: [get_field: 2, put_change: 3]

  @doc """
  Generated random string gives of length
  ***(İngizlizcem bu kadardı :)))
   **Not: Abdulkadir DİLSİZ
  """
  def random(length) do
    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64
    |> binary_part(0, length)
  end

  def to_slug(string, :extension) do
    string = Slugger.slugify_downcase(string)
    string = String.split(string, "-")
    last = List.last(string)
    string = List.delete_at(string, Enum.count(string) - 1)
    string = Enum.join(string, "-")
    string <> "." <> last
  end

  def to_slug(changeset = %Ecto.Changeset{}, field) do
    if changeset.valid? do
      put_change(changeset, :slug, 
        Slugger.slugify_downcase(get_field(changeset, field)))
    else 
      changeset
    end
  end

  def to_slug(changeset = %Ecto.Changeset{}) do
    if changeset.valid? do
      put_change(changeset, :slug, 
        Slugger.slugify_downcase(get_field(changeset, :name)))
    else 
      changeset
    end
  end

  def to_slug(string) do
    Slugger.slugify_downcase(string)
  end
end