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
defmodule Commodity.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common datastructures and query the data layer.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """
  use ExUnit.CaseTemplate

  import Ecto.Query

  alias Commodity.Api.Iam.User
  alias Commodity.Repo
  alias Commodity.AuthHelper

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest
      import Commodity.Router.Helpers

      alias Commodity.Api.Iam.User
      alias Commodity.Repo
      alias Commodity.AuthHelper

      alias Commodity.Api.Iam.AccessControl.Permission
      alias Commodity.Api.Iam.AccessControl.PermissionSet
      alias Commodity.Api.Iam.AccessControl.PermissionSetPermission
      alias Commodity.Api.Iam.AccessControl.PermissionSetGrant

      import Commodity.Api.Util.Type.String
      import Commodity.Api.Util.Type.DateTime

      alias Commodity.Elastic

      # The default endpoint for testing
      @endpoint Commodity.Endpoint
      @redis_keys Application.get_env(:commodity, :redis_keys)
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Commodity.Repo)
    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Commodity.Repo, {:shared, self()})
    end

    conn = Phoenix.ConnTest.build_conn()

    cond do
      tags[:login] == :user ->
        query = from u in User,
                join: up in User.Passphrase,
                  on: u.id == up.user_id,
                limit: 1,
                order_by: [asc: u.id],
                select: {u, up}

        {user, passphrase} = Repo.one!(query)

        conn = fetch_and_assign_token(conn, user, passphrase)

        {:ok, conn: conn, user: user}
      tags[:login] == :user_two ->
        query = from u in User,
                join: up in User.Passphrase,
                  on: u.id == up.user_id,
                limit: 1,
                offset: 1,
                order_by: [asc: u.id],
                select: {u, up}

        {user, passphrase} = Repo.one!(query)

        conn = fetch_and_assign_token(conn, user, passphrase)

        {:ok, conn: conn, user: user}
      true ->
       {:ok, conn: conn}
    end
  end

  defp fetch_and_assign_token(conn, user = %User{}, passphrase) do
    conn
    |> Plug.Conn.put_req_header("accept", "application/json")
    |> AuthHelper.issue_token(user, passphrase)
    |> Plug.Conn.assign(:setup_user, user)
    |> Plug.Conn.assign(:user_id, user.id)
    |> Plug.Conn.assign(:passphrase_id, passphrase.id)
  end
end
