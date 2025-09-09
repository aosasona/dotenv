import dot_env/internal/parser
import gleam/io
import gleam/list
import gleam/result.{try}
import gleam/string

pub type ValidationResult {
  Valid
  MissingKeys(List(String))
  ExtraKeys(List(String))
  BothMissingAndExtra(missing: List(String), extra: List(String))
}

pub type ExampleFileConfig {
  ExampleFileConfig(
    /// Path to the example file
    path: String,
    /// Whether to warn about extra keys in the current env file
    warn_extra_keys: Bool,
    /// Whether to warn about missing keys from the example file
    warn_missing_keys: Bool,
  )
}

/// Default configuration for example file validation
pub const default_config = ExampleFileConfig(
  path: ".env.example",
  warn_extra_keys: False,
  warn_missing_keys: True,
)

/// Find the example file path based on the current env file path
/// Supports patterns like:
/// - .env -> .env.example
/// - .env.local -> .env.local.example
/// - config/.env -> config/.env.example
pub fn find_example_file_path(env_file_path: String) -> String {
  case string.ends_with(env_file_path, ".env") {
    True -> env_file_path <> ".example"
    False -> {
      case string.ends_with(env_file_path, ".env.") {
        True -> env_file_path <> "example"
        False -> env_file_path <> ".example"
      }
    }
  }
}

/// Validate the current environment file against an example file
pub fn validate_against_example(
  current_env_content: String,
  example_file_content: String,
  config: ExampleFileConfig,
) -> Result(ValidationResult, String) {
  use current_keys <- try(extract_keys(current_env_content))
  use example_keys <- try(extract_keys(example_file_content))

  let missing_keys =
    list.filter(example_keys, fn(key) { !list.contains(current_keys, key) })

  let extra_keys = case config.warn_extra_keys {
    True ->
      list.filter(current_keys, fn(key) { !list.contains(example_keys, key) })
    False -> []
  }

  case missing_keys, extra_keys {
    [], [] -> Ok(Valid)
    missing, [] -> Ok(MissingKeys(missing))
    [], extra -> Ok(ExtraKeys(extra))
    missing, extra -> Ok(BothMissingAndExtra(missing: missing, extra: extra))
  }
}

/// Extract just the keys from an environment file content
fn extract_keys(content: String) -> Result(List(String), String) {
  use kv_pairs <- try(parser.parse(content))

  Ok(
    list.map(kv_pairs, fn(pair) {
      let #(key, _) = pair
      key
    }),
  )
}

/// Print validation warnings to the console
pub fn print_validation_warnings(
  result: ValidationResult,
  current_file: String,
  example_file: String,
) -> Nil {
  case result {
    Valid -> Nil
    MissingKeys(missing) -> {
      io.println_error(
        "⚠️  Warning: Missing keys in "
        <> current_file
        <> " compared to "
        <> example_file
        <> ":",
      )
      list.each(missing, fn(key) { io.println_error("   - " <> key) })
    }
    ExtraKeys(extra) -> {
      io.println_error(
        "⚠️  Warning: Extra keys in "
        <> current_file
        <> " not found in "
        <> example_file
        <> ":",
      )
      list.each(extra, fn(key) { io.println_error("   + " <> key) })
    }
    BothMissingAndExtra(missing, extra) -> {
      io.println_error(
        "⚠️  Warning: Environment file validation issues between "
        <> current_file
        <> " and "
        <> example_file
        <> ":",
      )

      case missing {
        [] -> Nil
        _ -> {
          io.println_error("   Missing keys:")
          list.each(missing, fn(key) { io.println_error("     - " <> key) })
        }
      }

      case extra {
        [] -> Nil
        _ -> {
          io.println_error("   Extra keys:")
          list.each(extra, fn(key) { io.println_error("     + " <> key) })
        }
      }
    }
  }
}
