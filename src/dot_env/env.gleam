import gleam/int
import gleam/result
import gleam/string

/// Set an environment variable (supports both Erlang and JavaScript targets)
///
/// ## Usage
///
/// ```gleam
/// import dot_env/env
///
/// fn main() {
///   env.set("APP_NAME", "app")
///
///   Nil
/// }
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
/// ## Usage
///
/// ```gleam
/// import dot_env/env
/// import gleam/io
/// import gleam/result
///
/// fn main() {
///   env.get_string("APP_NAME")
///   |> result.unwrap("app")
///   |> io.println
/// }
/// ```
///
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
///
/// ## Usage
///
/// ```gleam
/// import dot_env/env
/// import gleam/io
///
/// fn main() {
///   let app_name = env.get_string_or("APP_NAME", "My App")
///   io.println(app_name)
/// }
/// ```
///
pub fn get_string_or(key: String, default: String) -> String {
  get_string(key)
  |> result.unwrap(default)
}

/// An alternative implementation of `get` that allows for chaining using `use` statements and for early returns.
///
/// ## Usage
///
/// ```gleam
/// import dot_env/env
/// import gleam/io
///
/// fn main() {
///   use app_name <- env.get_then("APP_NAME")
///   io.println(app_name)
/// }
/// ```
///
pub fn get_then(
  key: String,
  next: fn(String) -> Result(t, String),
) -> Result(t, String) {
  case get_string(key) {
    Ok(value) -> next(value)
    Error(err) -> Error(err)
  }
}

/// Get an environment variable as an integer (this is the same as calling `get_string` and then parsing the `Ok` value)
///
/// ## Usage
///
/// ```gleam
/// import dot_env/env
/// import gleam/io
/// import gleam/result
///
/// fn main() {
///   env.get_int("PORT")
///   |> result.unwrap(9000)
///   |> io.println
/// }
/// ```
///
pub fn get_int(key: String) -> Result(Int, String) {
  use raw_value <- get_then(key)

  int.parse(raw_value)
  |> result.map_error(fn(_) {
    "Failed to parse environment variable for `" <> key <> "` as integer"
  })
}

/// Get an environment variable as an integer or return a default value if it is not set
///
/// ## Usage
///
/// ```gleam
/// import dot_env/env
/// import gleam/io
///
/// fn main() {
///   let port = env.get_int_or("PORT", 9000)
///   io.debug(port)
/// }
/// ```
///
pub fn get_int_or(key: String, default: Int) -> Int {
  get_int(key)
  |> result.unwrap(default)
}

/// Get an environment variable as a boolean
///
/// ## Usage
///
/// ```gleam
/// import dot_env/env
/// import gleam/io
/// import gleam/result
///
/// fn main() {
///   env.get_bool("IS_DEBUG")
///   |> result.unwrap(False)
///   |> io.println
/// }
/// ```
///
pub fn get_bool(key: String) -> Result(Bool, String) {
  use raw_value <- get_then(key)

  case string.lowercase(raw_value) {
    "true" | "1" -> Ok(True)
    "false" | "0" -> Ok(False)
    _ ->
      Error(
        "Invalid boolean value for environment variable `"
        <> key
        <> "`. Expected one of `true`, `false`, `1`, or `0`.",
      )
  }
}

/// Get an environment variable as a boolean or return a default value if it is not set
///
/// ## Usage
///
/// ```gleam
/// import dot_env/env
/// import gleam/io
///
/// fn main() {
///   let is_debug = env.get_bool_or("IS_DEBUG", True)
///   io.debug(is_debug)
/// }
/// ```
///
pub fn get_bool_or(key: String, default: Bool) -> Bool {
  get_bool(key)
  |> result.unwrap(default)
}
