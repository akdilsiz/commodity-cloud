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
defmodule Commodity.MixProject do
  use Mix.Project

  def project do
    [
      app: :commodity,
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test, "coveralls.detail": :test, "coveralls.html": :test],
      #Documentation
      name: "Commodity Cloud",
      source_url: "http://github.com/akdilsiz/commodity-cloud",
      homepage_url: "https://commodity.tecpor.com",
      docs: [main: "Commodity Cloud",
             extras: ["README.md"]]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Commodity.Application, []},
      extra_applications: [:logger, :runtime_tools, :jose, :comeonin, :mime,
                          :timex, :amqp, :rediscl, :httpoison, :lager]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.4.2"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_ecto, "~> 4.0"},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:ex_machina, "~> 2.2", only: :test},
      {:comeonin, "~> 4.1"},
      {:bcrypt_elixir, "~> 1.1"},
      {:credo, "~> 1.0.0", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.10", only: :test},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:jose, "~> 1.9"},
      {:cors_plug, "~> 2.0"},
      {:ecto_enum, "~> 1.2"},
      {:mime, "~> 1.2"},
      {:geo_postgis, "~> 2.0"},
      {:inet_cidr, "~> 1.0.0"},
      {:distillery, "~> 2.0"},
      {:timex, "~> 3.1"},
      {:logster, "~> 0.10"},
      {:amqp, "~> 1.1"},
      {:rediscl, "~> 0.1"},
      {:slugger, "~> 0.3"},
      {:lager, "~> 3.6"},
      {:httpoison, "~> 1.4"},
      {:sweet_xml, "~> 0.6.5"},
      {:html_sanitize_ex, "~> 1.3"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
