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
# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :commodity,
  ecto_repos: [Commodity.Repo]

config :commodity, Commodity.Repo, migration_timestamps: [type: :naive_datetime_usec]

config :geo_postgis,
  json_library: Jason

config :postgrex, :json_library, Jason  

# Configures the endpoint
config :commodity, Commodity.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "mFlnOYdd3SSz6eB8g9SBsyw9nBC9i7Tl2v0wAieHgPAUtQ8lNeBgPgVQFii9AEPP",
  render_errors: [view: Commodity.Api.Util.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Commodity.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :logster, :filter_parameters, 
  ["password", "secret", "token", "family_name", "email", "phone_number",
  "passphrase"]

config :commodity, :jwt,
  iss: "Commodity",
  exp: 60 * 5

config :commodity, :jwk,
  secret_key_base: "p0rZf9k4a8+J9FcAmeMqal7nP2VPxBDV76H+LkvxNxR3gUloW1vHjXV0Ry3y3XGw"

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :phoenix, :format_encoders,
  json: Jason

config :cors_plug,
  origin: ["*"],
  maxage: 86_400,
  methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "HEAD"]

config :slugger, separator_char: ?-

config :lager, :crash_log, false

config :lager, [
  handlers: [
    lager_console_backend: [{:level, :critical}],
  ]
]

config :lager, :error_logger_redirect, false
config :lager, :error_logger_whitelist, [Logger.ErrorHandler]

config :cors_plug,
  headers: ["Authorization", "Content-Type", "Accept", "Origin",
             "User-Agent", "DNT","Cache-Control", "X-Mx-ReqToken",
             "Keep-Alive", "X-Requested-With", "If-Modified-Since",
            "X-CSRF-Token", "X-Commodity-Company", "X-Commodity-Timezone", "X-Ahtpaot-Language"]

config :commodity, :elasticsearch,
  settings: %{
    settings: %{
      analysis: %{
        analyzer: %{
          default: %{
            tokenizer: "standard",
            filter: ["standard", "tr_folding", "lowercase"]
          }
        },
        filter: %{
          tr_folding: %{
            type: "asciifolding",
            preserve_original: true
          },
          lowercase: %{
            type: "lowercase",
            preserve_original: true
          }
        }
      }
    }
  },
  mappings: %{
    user: %{
        properties: %{
          location: %{
            type: "geo_point"
          }
        }
    }
  }

config :commodity, :redis_keys,
  permission: %{cache: "user:permission",
                cache_type: "user:permission:types"},
  user: %{all: "users",
          one: "user",
          personal_information: %{one: "user:personal_information"},
          email: %{all: "user:emails",
                  one: "user:email",
                  primary: "user:email:primary"},
          phone_number: %{all: "user:phones",
                          one: "user:phone",
                          primary: "user:phone:primary"},
          passphrase: %{one: "passphrase"},
          address: %{all: "user:addresses",
                    one: "user:address",
                    primary: "user:address:primary"},
          state: "user:state"}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
