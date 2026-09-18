import dot_env/config
import dot_env/env
import dot_env/parser
import gleam/bool
import gleam/io
import gleam/result.{try}
import gleam/string
import simplifile

pub opaque type DotEnv {
  DotEnv(config: config.Config)
}

/// Create a new instance of the DotEnv module with the specified configuration
pub fn new(config config: config.Config) -> DotEnv {
  config |> DotEnv(config: _)
}

/// Create a new instance of the DotEnv module with the default configuration
pub fn default() -> DotEnv {
  config.default |> DotEnv(config: _)
}

/// Get the configuration of the DotEnv instance
pub fn get_config(instance instance: DotEnv) -> config.Config {
  instance.config
}
