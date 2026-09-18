import gleam/list

pub type Value {
  /// The paths to the .env files to load. If multiple paths are provided, they will be loaded in order, with later files overriding earlier ones.
  Paths(List(String))

  /// Force all keys to be uppercase
  Capitalize(Bool)

  /// Print debug information if something goes wrong
  Debug(Bool)

  /// In case the file is missing, ignore the error and continue
  IgnoreMissingFile(Bool)
}

/// A list of options to configure the behavior of the DotEnv loader
pub type Config =
  List(Value)

/// The default options for loading the .env file
pub const default = [
  Paths([".env"]),
  Capitalize(True),
  Debug(True),
  IgnoreMissingFile(True),
]

/// Get the name of the option as a string
/// This is useful for debugging and logging purposes, and also for filtering options by name. For example, you can use this function to check if a specific option is present in the list of options.
pub fn name(option: Value) -> String {
  case option {
    Paths(_) -> "Paths"
    Capitalize(_) -> "Capitalize"
    Debug(_) -> "Debug"
    IgnoreMissingFile(_) -> "IgnoreMissingFile"
  }
}

/// Check if the options is set to ignore missing file errors
pub fn ignore_missing_file(config: Config) -> Bool {
  case config {
    [IgnoreMissingFile(ignore), ..] -> ignore
    _ -> False
  }
}

/// Check if the options is set to capitalize all keys
pub fn capitalize(config: Config) -> Bool {
  case config {
    [Capitalize(capitalize), ..] -> capitalize
    _ -> False
  }
}

/// Check if the options is set to print debug information
pub fn debug(config: Config) -> Bool {
  case config {
    [Debug(debug), ..] -> debug
    _ -> False
  }
}

/// Get the paths to the .env files to load from the options
pub fn paths(config: Config) -> List(String) {
  case config {
    [Paths(paths), ..] -> paths
    _ -> []
  }
}

/// Set the paths to the .env files to load in the options
pub fn set_paths(config: Config, paths: List(String)) -> Config {
  Paths(paths) |> replace_option(config)
}

/// Add a path to the list of paths to load in the options
pub fn add_path(config: Config, path: String) -> Config {
  let existing_paths = paths(config)
  let new_paths = [path, ..existing_paths]
  Paths(new_paths) |> replace_option(config)
}

/// Set whether to capitalize all keys in the options
pub fn set_capitalize(config: Config, capitalize: Bool) -> Config {
  Capitalize(capitalize) |> replace_option(config)
}

/// Set whether to print debug information in the options
pub fn set_debug(config: Config, debug: Bool) -> Config {
  Debug(debug) |> replace_option(config)
}

/// Set whether to ignore missing file errors in the options
pub fn set_ignore_missing_file(config: Config, ignore: Bool) -> Config {
  IgnoreMissingFile(ignore) |> replace_option(config)
}

/// Apply the option to the list of options, replacing any existing option with the same name
fn replace_option(option: Value, config: Config) -> Config {
  let option_name = name(option)

  config
  |> list.filter(fn(existing) { name(existing) != option_name })
  |> list.prepend(option)
}
