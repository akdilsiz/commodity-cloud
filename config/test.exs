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
use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :commodity, Commodity.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :commodity, Commodity.Repo,
  username: "commodity",
  password: "commodity",
  database: "commodity_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :bcrypt_elixir, log_rounds: 1

config :rediscl,
  host: "127.0.0.1",
  port: 6379,
  password: "",
  database: 2,
  pool: 15,
  timeout: 15_000

config :commodity, :elasticsearch,
  host: "localhost",
  port: 9200

config :commodity, :amqp,
  username: "local",
  password: "local",
  host: "localhost"

config :commodity, :env, :test
config :commodity, :trust_x_forwarded_for, true