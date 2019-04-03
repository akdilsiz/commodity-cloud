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
defmodule Commodity.ChannelCase do
  @moduledoc """
  This module defines the test case to be used by
  channel tests.

  Such tests rely on `Phoenix.ChannelTest` and also
  import other functionality to make it easier
  to build common datastructures and query the data layer.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  import Ecto.Query

  alias Commodity.Repo
  alias Commodity.Api.Iam.User
  alias Commodity.Api.Util.JWTView

  using do
    quote do
      # Import conveniences for testing with channels
      use Phoenix.ChannelTest

      alias Commodity.Repo
      alias Commodity.Api.Iam.User
      alias Commodity.Api.Iam.AccessControl.PermissionSet
      alias Commodity.Api.Iam.AccessControl.PermissionSetGrant
      
      # The default endpoint for testing
      @endpoint Commodity.Endpoint

      import Commodity.ChannelCase
    end
  end


  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Commodity.Repo)
    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Commodity.Repo, {:shared, self()})
    end

    cond do
      tags[:login] == :user ->
        query = from u in User,
                join: up in User.Passphrase,
                  on: u.id == up.user_id,
                limit: 1,
                order_by: [asc: u.id],
                select: {u, up}

        {user, passphrase} = Repo.one!(query)

        user = assign_token(user, passphrase)

        {:ok, user: user}
      true ->
        :ok
    end
  end

  defp assign_token(user = %User{}, passphrase) do
    jwk = %{
      "kty" => "oct",
      "k" => Keyword.fetch!(Application.get_env(:commodity, :jwk), :secret_key_base)
    }

    jws = %{
      "alg" => "HS256",
      "typ" => "JWT"
    }

    issuer = Keyword.fetch!(Application.get_env(:commodity, :jwt), :iss)
    expire =
      :os.system_time(:seconds) + Keyword.fetch!(Application.get_env(:commodity, :jwt), :exp)

    payload = %{"iss" => issuer,
                "exp" => expire,
                "sub" => "access"}

    jwt =
      payload
      |> Map.merge(JWTView.render("jwt.json", %{user: user, passphrase: passphrase}))

    {_, token} =
      JOSE.JWT.sign(jwk, jws, jwt)
      |> JOSE.JWS.compact()

    user =
      Map.put(user, :jwt, token)

    user
  end
end
