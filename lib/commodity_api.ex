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
defmodule Commodity.Api do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use Commodity, :controller
      use Commodity, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: Commodity

      import Plug.Conn
      import Commodity.Gettext
      alias Commodity.Router.Helpers, as: Routes

      alias Commodity.Repo
      import Ecto.Repo
      import Ecto.Query

      import Commodity.Api.Iam.Generic.AuthenticationPlug
      import Commodity.Api.Iam.Generic.AuthorizationPlug

      import Commodity.Api.Util.VirtualValidation

      import Commodity.Api.Util.Type.String
      import Commodity.Api.Util.Type.DateTime
      alias Commodity.Api.Util.PagingRequest

      alias Commodity.Api.Util.ChangesetView

      alias Commodity.Api.Util.Type.Integer, as: CInteger

      alias Commodity.Elastic

      @redis_keys Application.get_env(:commodity, :redis_keys)
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/commodity_web/templates",
        namespace: Commodity

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_csrf_token: 0,
        get_flash: 1, 
        get_flash: 2, 
        view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import Commodity.Api.Util.ErrorHelpers
      import Commodity.Gettext
      alias Commodity.Router.Helpers, as: Routes

      import Commodity.Router.Helpers

      import Commodity.Api.Util.Type.String
      import Commodity.Api.Util.Type.DateTime
      alias Commodity.Api.Util.Type.Integer, as: CInteger

      alias Commodity.Api.Util.TimeInformationView
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import Commodity.Gettext

      @redis_keys Application.get_env(:commodity, :redis_keys)
    end
  end

  def model do
    quote do
      use Ecto.Schema

      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      alias Commodity.Repo

      import Commodity.Api.Util.Type.String
      alias Commodity.Api.Util.Type.Integer, as: CInteger
    end
  end

  def viewmodel do
    quote do
      use Ecto.Schema

      import Ecto
      import Ecto.Query
    end
  end

  def virtual do
    quote do
      use Ecto.Schema

      import Ecto.Changeset
      import Commodity.Api.Util.Type.String
      alias Commodity.Api.Util.Type.Integer, as: CInteger
    end
  end

  def plug do
    quote do
      import Plug.Conn
      import Ecto.Query
      alias Commodity.Repo

      @redis_keys Application.get_env(:commodity, :redis_keys)
    end
  end

  def policy do
    quote do
      alias Commodity.Repo
      import Ecto
      import Ecto.Query
    end
  end

  def library do
    quote do
      use Phoenix.Controller

      alias Commodity.Repo
      import Ecto
      import Ecto.Query

      alias Commodity.Router.Helpers, as: Routes
      import Commodity.Router.Helpers
      import Commodity.Api.Util.VirtualValidation
      import Commodity.Gettext
      import Commodity.Api.Util.Type.String
      import Commodity.Api.Util.Type.DateTime
      alias Commodity.Api.Util.Type.Integer, as: CInteger

      alias Commodity.Elastic

      require Logger

      @redis_keys Application.get_env(:commodity, :redis_keys)
    end
  end

  def task do
    quote do
      alias Commodity.Repo
      import Ecto
      import Ecto.Query

      import Commodity.Api.Util.Type.String,
      import Commodity.Api.Util.Type.DateTime
      alias Commodity.Api.Util.Type.Integer, as: CInteger

      alias Commodity.Elastic

      @redis_keys Application.get_env(:commodity, :redis_keys) 
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
