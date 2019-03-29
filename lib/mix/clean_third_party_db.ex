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
defmodule Mix.Tasks.Commodity.Clean.Thirdparty.Db do
  @moduledoc """
  Clear thirdparty databases all contents
  """
  use Mix.Task

  alias Commodity.Api.Generic.CleanThirdpartyDb

  require Logger

  @shortdoc "Clear all thirdparty database contents"

  def run(_) do
    Logger.configure(level: :info)
    Logger.configure_backend(:console,
      format: "$time $metadata[$level] $levelpad$message\n")

    Logger.info "== Running Commodity.Clean.Thirdparty.Db"

    Mix.Task.run "app.start"

    CleanThirdpartyDb.clean_and_generate()

    Logger.info "== Completed Commodity.Clean.Thirdparty.Db"
  end
end
