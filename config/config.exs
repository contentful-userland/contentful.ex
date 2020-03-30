# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# optional parameters
config :contentful, json_library: Jason

# config :contentful, delivery: [
#   access_token: "<YOUR_CDA_TOKEN>", # <- recommended to put into secrets
#   environment: "master" # default for every function call
#   space: "your-space" # recommended to set, can be passed to all calls as well.
# ]

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#

extendend_config = "#{Mix.env()}.exs"
extendend_config_secret = "secrets.#{Mix.env()}.exs"

if File.exists?("config/#{extendend_config}") do
  import_config extendend_config
end

if File.exists?("config/#{extendend_config_secret}") do
  import_config extendend_config_secret
end
