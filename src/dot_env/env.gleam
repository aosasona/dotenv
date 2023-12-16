import gleam/int
import gleam/result

/// Set an environment variable (supports both Erlang and JavaScript targets)
///
/// Example:
/// ```gleam
/// import dot_env/env
///
/// env.set("MY_ENV_VAR", "my value")
/// ```
///
@external(erlang, "dot_env_ffi", "set_env")
@external(javascript, "../dot_env_ffi.mjs", "set_env")
pub fn set(key: String, value: String) -> Nil

/// Get an environment variable (supports both Erlang and JavaScript targets)
///
/// Example:
/// ```gleam
/// import dot_env/env
/// import gleam/io
/// import gleam/result
///
/// env.get("MY_ENV_VAR")
/// |> result.unwrap("NOT SET")
/// |> io.println
/// ```
@external(erlang, "dot_env_ffi", "get_env")
@external(javascript, "../dot_env_ffi.mjs", "get_env")
pub fn get(key: String) -> Result(String, String)

/// Get an environment variable or return a default value
pub fn get_or(key: String, default: String) -> String {
  case get(key) {
    Ok(value) -> value
    Error(_) -> default
  }
}

/// Get an environment variable as an integer
pub fn get_int(key: String) -> Result(Int, String) {
  case get(key) {
    Ok(value) -> {
      int.parse(value)
      |> result.map_error(fn(_) {
        "Failed to parse string to int, confirm the value you are trying to retrieve is a valid integer"
      })
    }
    Error(e) -> Error(e)
  }
}

/// Get an environment variable as a boolean
pub fn get_bool(key: String) -> Result(Bool, String) {
  case get(key) {
    Ok(value) -> {
      case value {
        "True" | "true" | "1" -> Ok(True)
        _ -> Ok(False)
      }
    }
    Error(e) -> Error(e)
  }
}
