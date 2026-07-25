pub type Option {
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
pub type Options =
  List(Option)

/// The default options for loading the .env file
const default = [
  Paths([".env"]),
  Capitalize(True),
  Debug(True),
  IgnoreMissingFile(True),
]

/// Check if the options is set to ignore missing file errors
pub fn ignore_missing_file(options: Options) -> Bool {
  case options {
    [IgnoreMissingFile(ignore), ..] -> ignore
    _ -> False
  }
}

/// Check if the options is set to capitalize all keys
pub fn capitalize(options: Options) -> Bool {
  case options {
    [Capitalize(capitalize), ..] -> capitalize
    _ -> False
  }
}

/// Check if the options is set to print debug information
pub fn debug(options: Options) -> Bool {
  case options {
    [Debug(debug), ..] -> debug
    _ -> False
  }
}

/// Get the paths to the .env files to load from the options
pub fn paths(options: Options) -> List(String) {
  case options {
    [Paths(paths), ..] -> paths
    _ -> []
  }
}

/// Set the paths to the .env files to load in the options
pub fn set_paths(options: Options, paths: List(String)) -> Options {
  [Paths(paths), ..options]
}

/// Set whether to capitalize all keys in the options
pub fn set_capitalize(options: Options, capitalize: Bool) -> Options {
  [Capitalize(capitalize), ..options]
}

/// Set whether to print debug information in the options
pub fn set_debug(options: Options, debug: Bool) -> Options {
  [Debug(debug), ..options]
}

/// Set whether to ignore missing file errors in the options
pub fn set_ignore_missing_file(options: Options, ignore: Bool) -> Options {
  [IgnoreMissingFile(ignore), ..options]
}
