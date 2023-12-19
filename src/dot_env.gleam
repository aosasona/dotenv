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

  dotenv
  |> load_and_return_error
  |> fn(r) {
    case r {
      Ok(_) -> Nil
      Error(msg) -> {
        case dotenv.debug {
          True -> io.println_error(msg)
          False -> Nil
        }
      }
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

fn recursively_set_environment_variables(
  config: DotEnv,
  kv_pairs: parser.EnvPairs,
) {
  case kv_pairs {
    [] -> Nil
    [pair] -> {
      env.set(
        case config.capitalize {
          True -> string.uppercase(pair.0)
          False -> pair.0
        },
        pair.1,
      )
    }
    [pair, ..rest] -> {
      env.set(
        case config.capitalize {
          True -> string.uppercase(pair.0)
          False -> pair.0
        },
        pair.1,
      )
      recursively_set_environment_variables(config, rest)
    }
  }
}

fn read_file(dotenv: DotEnv) -> Result(String, String) {
  case simplifile.is_file(dotenv.path) {
    True -> {
      case simplifile.read(dotenv.path) {
        Ok(contents) -> Ok(contents)
        Error(_) -> {
          let msg =
            "Unable to read file at `"
            <> dotenv.path
            <> "`, ensure the file exists and is readable"
          io.println(msg)
          Error(msg)
        }
      }
    }
    False -> Error("Specified file `" <> dotenv.path <> "` does not exist")
  }
}
