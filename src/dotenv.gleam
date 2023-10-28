import gleam/io
import gleam/erlang/os
import gleam/result.{try}
import dotenv/internal/parser
import simplifile

pub type Opts {
  Opts(path: String, debug: Bool, capitalize: Bool)
  Default
}

pub opaque type DotEnv {
  DotEnv(path: String, debug: Bool, capitalize: Bool)
}

const default = DotEnv(path: ".env", debug: False, capitalize: False)

pub fn load() -> Result(Nil, String) {
  load_with_opts(Default)
}

pub fn load_with_opts(opts: Opts) -> Result(Nil, String) {
  let dotenv = case opts {
    Opts(path, debug, capitalize) -> DotEnv(path, debug, capitalize)
    Default -> default
  }

  use content <- try(read_file(dotenv))
  use kv_pairs <- try(parser.parse(content))

  recursively_set_environment_variables(kv_pairs)

  Ok(Nil)
}

fn recursively_set_environment_variables(kv_pairs: parser.EnvPairs) {
  case kv_pairs {
    [pair, ..rest] -> {
      os.set_env(pair.0, pair.1)
      recursively_set_environment_variables(rest)
    }
    [] -> Nil
  }
}

fn read_file(dotenv: DotEnv) -> Result(String, String) {
  case simplifile.is_file(dotenv.path) {
    True -> {
      case simplifile.read(dotenv.path) {
        Ok(contents) -> Ok(contents)
        Error(_) -> {
          let msg =
            "Unable to read file at `" <> dotenv.path <> "`, ensure the file exists and is readable"
          io.println(msg)
          Error(msg)
        }
      }
    }
    False -> Error("Specified file `" <> dotenv.path <> "` does not exist")
  }
}
