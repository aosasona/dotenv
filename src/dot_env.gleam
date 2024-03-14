import gleam/bool
import gleam/io
import gleam/string
import gleam/result.{try}
import dot_env/internal/parser
import dot_env/env
import simplifile

pub type Opts {
  /// Customized options for loading the .env file
  Opts(
    /// The path to the .env file relative to the project root eg. .env and src/.env are two different things, .env points to the root of the project, src/.env points to the src folder in the root of the project
    path: String,
    /// Print debug information if something goes wrong
    debug: Bool,
    /// Force all keys to be uppercase
    capitalize: Bool,
  )

  /// Default options for loading the .env file - see `default` constant
  Default
}

pub opaque type DotEnv {
  DotEnv(path: String, debug: Bool, capitalize: Bool)
}

pub const default = DotEnv(path: ".env", debug: True, capitalize: True)

///
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
///   dot_env.load()
/// }
/// ```
pub fn load() {
  load_with_opts(Default)
}

///
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
    Opts(path, debug, capitalize) -> DotEnv(path, debug, capitalize)
    Default -> default
  }

  let state =
    dotenv
    |> load_and_return_error

  case state {
    Ok(_) -> Nil
    Error(msg) -> {
      use <- bool.guard(when: !dotenv.debug, return: Nil)
      io.println_error(msg)
    }
  }
}

fn load_and_return_error(dotenv: DotEnv) -> Result(Nil, String) {
  use content <- try(read_file(dotenv))
  use kv_pairs <- try(parser.parse(content))

  dotenv
  |> recursively_set_environment_variables(kv_pairs)

  Ok(Nil)
}

fn set_env(config: DotEnv, pair: #(String, String)) {
  let #(key, value) = pair

  let key = {
    use <- bool.guard(when: !config.capitalize, return: key)
    string.uppercase(key)
  }

  env.set(key, value)
}

fn recursively_set_environment_variables(
  config: DotEnv,
  kv_pairs: parser.KVPairs,
) {
  case kv_pairs {
    [] -> Nil
    [pair] -> set_env(config, pair)
    [pair, ..rest] -> {
      set_env(config, pair)
      recursively_set_environment_variables(config, rest)
    }
  }
}

fn read_file(dotenv: DotEnv) -> Result(String, String) {
  use is_file <- result.try(
    simplifile.verify_is_file(dotenv.path)
    |> result.map_error(with: fn(_) {
      "Failed to access file, ensure the file exists and is a readable file"
    }),
  )

  use <- bool.guard(
    when: !is_file,
    return: Error("Specified file does not exist"),
  )

  use contents <- result.try(
    simplifile.read(dotenv.path)
    |> result.map_error(with: fn(_) {
      let msg =
        "Unable to read file at `"
        <> dotenv.path
        <> "`, ensure the file exists and is readable"
      msg
    }),
  )

  Ok(contents)
}
