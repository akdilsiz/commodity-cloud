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
defmodule Commodity.Router do
  use Commodity.Api, :router

  pipeline :api do
    plug CORSPlug, [origin: "*"]
    plug :accepts, ["json"]
    plug Commodity.Api.Generic.TimeInformationPlug
    plug Commodity.Api.Generic.Plug.PublicIp
  end

  scope "/", Commodity.Api do
    pipe_through :api

    scope "/user", as: "iam" do
      options "/sign_in",
              Iam.AccessControl.PassphraseController,
              :options
      resources "/sign_in",
                Iam.AccessControl.PassphraseController,
                only: [:create],
                assigns: %{name: "user/sign_in"}

      options "/sign_in/token",
              Iam.AccessControl.TokenController,
              :options
      resources "/sign_in/token",
                Iam.AccessControl.TokenController,
                only: [:create],
                assigns: %{name: "user/sign_in/token"}

      options "/confirmation",
              Iam.AccessControl.ConfirmationController,
              :options
      resources "/confirmation",
                Iam.AccessControl.ConfirmationController,
                only: [:show],
                signleton: true,
                assigns: %{name: "user/confirmation"}

      scope "/new", as: "new" do
        options "/",
              Iam.AccessControl.UserController,
              :options
        resources "/",
                  Iam.AccessControl.UserController,
                  only: [:create],
                  assigns: %{name: "user/new"}
      end

      options "/",
            Iam.UserController,
            :options
      options "/:anything",
            Iam.UserController,
            :options
      resources "/", 
                Iam.UserController,
                only: [:index, :show, :create, :delete],
                assigns: %{name: "user"} do

                options "/sign_out",
                        Iam.AccessControl.Passphrase.InvalidationController,
                        :options
                resources "/sign_out",
                        Iam.AccessControl.Passphrase.InvalidationController,
                        only: [:create],
                        assigns: %{name: "user/sign_out"}
      end
    end
  end
end
