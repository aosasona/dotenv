import gleam/int
import gleam/result
import gleam/string

/// Set an environment variable (supports both Erlang and JavaScript targets)
///
/// Example:
/// ```gleam
/// import dot_env/env
///
/// env.set("FOO", "my value")
/// ```
///
@external(erlang, "dot_env_ffi", "set_env")
@external(javascript, "../dot_env_ffi.mjs", "set_env")
pub fn set(key: String, value: String) -> Result(Nil, String)

/// Get an environment variable (supports both Erlang and JavaScript targets)
///
/// Example:
/// ```gleam
/// import dot_env/env
/// import gleam/io
/// import gleam/result
///
/// env.get("FOO")
/// |> result.unwrap("NOT SET")
/// |> io.println
/// ```
@deprecated("Use `get_string` instead, this will be removed in the next release")
@external(erlang, "dot_env_ffi", "get_env")
@external(javascript, "../dot_env_ffi.mjs", "get_env")
pub fn get(key: String) -> Result(String, String)

/// Get an environment variable (supports both Erlang and JavaScript targets)
///
/// Example:
/// ```gleam
/// import dot_env/env
/// import gleam/io
/// import gleam/result
///
/// env.get_string("FOO")
/// |> result.unwrap("NOT SET")
/// |> io.println
/// ```
@external(erlang, "dot_env_ffi", "get_env")
@external(javascript, "../dot_env_ffi.mjs", "get_env")
pub fn get_string(key: String) -> Result(String, String)

/// Get an environment variable or return a default value if it is not set
@deprecated("Use `get_string_or` instead, this will be removed in the next release")
pub fn get_or(key: String, default: String) -> String {
  get_string(key)
  |> result.unwrap(default)
}

/// Get an environment variable or return a default value if it is not set
pub fn get_string_or(key: String, default: String) -> String {
  get_string(key)
  |> result.unwrap(default)
}

/// An alternative implementation of `get` that allows for chaining using `use`
pub fn get_then(
  key: String,
  f: fn(String) -> Result(t, String),
) -> Result(t, String) {
  case get_string(key) {
    Ok(value) -> f(value)
    Error(err) -> Error(err)
  }
}

/// Get an environment variable as an integer
pub fn get_int(key: String) -> Result(Int, String) {
  use raw_value <- get_then(key)

  int.parse(raw_value)
  |> result.map_error(fn(_) {
    "Failed to parse environment variable for `" <> key <> "` as integer"
  })
}

/// Get an environment variable as an integer or return a default value if it is not set
pub fn get_int_or(key: String, default: Int) -> Int {
  get_int(key)
  |> result.unwrap(default)
}

/// Get an environment variable as a boolean
pub fn get_bool(key: String) -> Result(Bool, String) {
  use raw_value <- get_then(key)

  case string.lowercase(raw_value) {
    "true" | "1" -> Ok(True)
    "false" | "0" -> Ok(True)
    _ ->
      Error(
        "Invalid boolean value for environment variable `"
        <> key
        <> "`. Expected one of `true`, `false`, `1`, or `0`.",
      )
  }
}

/// Get an environment variable as a boolean or return a default value if it is not set
pub fn get_bool_or(key: String, default: Bool) -> Bool {
  get_bool(key)
  |> result.unwrap(default)
}
