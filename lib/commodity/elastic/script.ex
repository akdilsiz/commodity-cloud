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
defmodule Commodity.Elastic.Script do
  @moduledoc """
  Commodity Elastic Search Http Client
  - Request scripts
  """

  @doc """
  Generate to script with given script name and key and value
  """
  def generate(script, key, value) 
      when script == :bulk_update_in_array_field_remove do
    Jason.encode!(%{"query" => %{"term" => %{key => value}},
                      "script" => "for(int i = 0; i < ctx._source.#{key}.length; i++) {" <>
                                    "if(ctx._source.#{key}[i] == #{value}) {"<>
                                      "ctx._source.#{key}.remove(i);"<>
                                    "}"<>
                                  "}"})
  end
end
