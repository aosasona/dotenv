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
