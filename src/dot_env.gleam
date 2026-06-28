import dot_env/env
import dot_env/internal/parser
import dot_env/internal/template
import gleam/bool
import gleam/io
import gleam/result.{try}
import gleam/string
import simplifile

pub type Opts {
  /// Customized options for loading the .env file
  Opts(
    /// The path to the .env file relative to the project root eg. .env and src/.env are two different things, .env points to the root of the project, src/.env points to the src folder in the root of the project
    path: String,
    /// Warn if variables defined in {path}.example are missing from the environment.
    check_example: Bool,
    /// Print debug information if something goes wrong
    debug: Bool,
    /// Force all keys to be uppercase
    capitalize: Bool,
    /// In case the file is missing, ignore the error and continue
    ignore_missing_file: Bool,
  )

  /// Default options for loading the .env file - see `default` constant
  Default
}

pub opaque type DotEnv {
  DotEnv(
    path: String,
    check_example: Bool,
    debug: Bool,
    capitalize: Bool,
    ignore_missing_file: Bool,
  )
}

pub const default = DotEnv(
  path: ".env",
  check_example: True,
  debug: True,
  capitalize: True,
  ignore_missing_file: True,
)

/// Create a default DotEnv instance. This is designed to be used as the starting point for using any of the builder methods
pub fn new() -> DotEnv {
  default
}

/// Create a new DotEnv instance with the specified path
pub fn new_with_path(path: String) -> DotEnv {
  DotEnv(..default, path: path)
}

/// Todo
pub fn set_check_example(instance: DotEnv, check_example: Bool) -> DotEnv {
  DotEnv(..instance, check_example: check_example)
}

/// Set whether to print debug information in the current DotEnv instance
pub fn set_debug(instance: DotEnv, debug: Bool) -> DotEnv {
  DotEnv(..instance, debug: debug)
}

/// Set whether to capitalize all keys in the current DotEnv instance
pub fn set_capitalize(instance: DotEnv, capitalize: Bool) -> DotEnv {
  DotEnv(..instance, capitalize: capitalize)
}

/// Set whether to ignore missing file errors in the current DotEnv instance
pub fn set_ignore_missing_file(
  instance: DotEnv,
  ignore_missing_file: Bool,
) -> DotEnv {
  DotEnv(..instance, ignore_missing_file: ignore_missing_file)
}

/// Set the path to the .env file in the current DotEnv instance
pub fn set_path(instance: DotEnv, path: String) -> DotEnv {
  DotEnv(..instance, path: path)
}

/// Get the path to the .env file in the current DotEnv instance
pub fn path(instance: DotEnv) -> String {
  instance.path
}

/// Load the .env file using the current DotEnv instance and set the environment variables
///
/// # Example
///
/// ```gleam
/// import dot_env as dot
///
/// pub fn main() {
///   dot.new()
///   |> dot.set_path("src/.env")
///   |> dot.set_debug(False)
///   |> dot.load
/// }
pub fn load(dotenv: DotEnv) -> Nil {
  load_with_opts(Opts(
    path: dotenv.path,
    check_example: dotenv.check_example,
    debug: dotenv.debug,
    capitalize: dotenv.capitalize,
    ignore_missing_file: dotenv.ignore_missing_file,
  ))
}

/// Load the .env file at the default path (.env) and set the environment variables
///
/// Debug information will be printed to the console if something goes wrong and all keys will be capitalized
///
/// # Example
///
/// ```gleam
/// import dot_env
///
/// pub fn main() {
///   dot_env.load_default()
/// }
/// ```
pub fn load_default() -> Nil {
  load_with_opts(Default)
}

/// Load the .env file at the specified path and set the environment variables
///
/// Debug information and key capitalization can be customized
///
/// # Example
///
/// ```gleam
/// import dot_env
///
/// pub fn main() {
///   dot_env.load_with_opts(dot_env.Opts(path: "src/.env", debug: False, capitalize: False))
/// }
/// ```
pub fn load_with_opts(opts: Opts) {
  let dotenv = case opts {
    Opts(path, check_example, debug, capitalize, ignore_missing_file) ->
      DotEnv(path, check_example, debug, capitalize, ignore_missing_file)
    Default -> default
  }

  case load_and_return_error(dotenv) {
    Ok(conf) -> check_template(dotenv, conf)
    Error(msg) -> {
      use <- bool.guard(when: !dotenv.debug, return: Nil)
      io.println_error(msg)
    }
  }
}

fn load_and_return_error(
  dotenv: DotEnv,
) -> Result(List(#(String, String)), String) {
  use content <- try(
    read_file(dotenv.path)
    |> handle_file_result(dotenv.ignore_missing_file),
  )

  use conf <- try(parser.parse(content))

  use _ <- try(dotenv |> recursively_set_environment_variables(conf))

  Ok(conf)
}

fn check_template(dotenv: DotEnv, conf: List(#(String, String))) -> Nil {
  use <- bool.guard(when: !dotenv.check_example, return: Nil)

  // maybe add example_path as an option?
  let template_path = dotenv.path <> ".example"

  let res = {
    use content <- try(read_file(template_path))
    use conf_example <- try(parser.parse(content))

    template.missing_keys(conf, conf_example, dotenv.capitalize)
    |> warn_missing_keys

    Ok(Nil)
  }

  case res {
    Ok(_) -> Nil
    Error(error) -> {
      let msg = case dotenv.debug {
        True -> error <> "\nSkipping template check"
        False -> "Skipping template check"
      }
      io.println_error(msg)
    }
  }
}

fn handle_file_result(
  res: Result(String, String),
  ignore_error: Bool,
) -> Result(String, String) {
  use <- bool.guard(when: result.is_error(res) && ignore_error, return: Ok(""))
  res
}

fn set_env(config: DotEnv, pair: #(String, String)) -> Result(Nil, String) {
  let key = {
    use <- bool.guard(when: !config.capitalize, return: pair.0)
    string.uppercase(pair.0)
  }

  key
  |> env.set(pair.1)
}

fn recursively_set_environment_variables(
  config: DotEnv,
  kv_pairs: parser.KVPairs,
) -> Result(Nil, String) {
  case kv_pairs {
    [] -> Ok(Nil)
    [pair] -> set_env(config, pair)
    [pair, ..rest] -> {
      use _ <- result.try(set_env(config, pair))
      recursively_set_environment_variables(config, rest)
    }
  }
}

fn read_file(path: String) -> Result(String, String) {
  use is_file <- result.try(
    simplifile.is_file(path)
    |> result.map_error(with: fn(_) {
      "Failed to access file, ensure the file exists and is a readable file"
    }),
  )

  use <- bool.guard(
    when: !is_file,
    return: Error("Specified file at `" <> path <> "` does not exist"),
  )

  use contents <- result.try(
    simplifile.read(path)
    |> result.map_error(with: fn(_) {
      "Unable to read file at `"
      <> path
      <> "`, ensure the file exists and is readable"
    }),
  )

  Ok(contents)
}

fn warn_missing_keys(keys: List(String)) {
  case keys {
    [] -> Nil
    _ -> {
      let joined_vars = string.join(keys, with: ", ")
      let warning_msg =
        "The following variables were defined in the example file but are not present in the environment:\n"
        <> "  "
        <> joined_vars
        <> "\n"
        <> "Make sure to add them to your env file."
      io.println_error(warning_msg)
    }
  }
}
