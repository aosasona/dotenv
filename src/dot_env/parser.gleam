import gleam/list
import gleam/result
import gleam/string

pub type KVPair =
  #(String, String)

pub type KVPairs =
  List(KVPair)

type Chars =
  List(String)

/// Parse key-value pairs from a string
///
/// The string can contain comments, which start with a `#` and continue to the end of the line
/// The parser also allows for unquoted values, which are terminated by a newline or a comment
pub fn parse(text: String) -> Result(KVPairs, String) {
  text
  |> explode_to_graphemes
  |> parse_kvs([])
}

/// Parse key-value pairs from a list of characters
fn parse_kvs(text: Chars, acc: KVPairs) -> Result(KVPairs, String) {
  case text {
    [] -> Ok(list.reverse(acc))
    ["\n", ..rest] | [" ", ..rest] -> parse_kvs(rest, acc)
    ["#", ..rest] -> parse_comment(rest, fn(r) { parse_kvs(r, acc) })
    ["e", "x", "p", "o", "r", "t", " ", ..rest] -> parse_kvs(rest, acc)
    _ -> {
      use #(pair, rest) <- result.try(parse_kv(text))
      parse_kvs(rest, [pair, ..acc])
    }
  }
}

/// Parse a single key-value pair from a list of characters
fn parse_kv(text: Chars) -> Result(#(KVPair, Chars), String) {
  use #(key, rest) <- result.try(parse_key(text, []))
  use #(value, rest) <- result.try(parse_value(rest))
  Ok(#(#(key, value), rest))
}

/// Parse a key from a list of characters
fn parse_key(text: Chars, acc: Chars) -> Result(#(String, Chars), String) {
  case text {
    ["=", ..rest] -> Ok(#(string.trim(join(acc)), rest))
    [c, ..rest] -> parse_key(rest, [c, ..acc])
    [] -> Error("unexpected end of input")
  }
}

/// Parse a value from a list of characters
/// Values can be unquoted, single-quoted, double-quoted, or backtick-quoted
fn parse_value(text: Chars) -> Result(#(String, Chars), String) {
  case text {
    ["\n", ..rest] -> Ok(#("", rest))
    ["\"", ..rest] -> parse_value_double_quoted(rest, [])
    ["'", ..rest] -> parse_value_single_quoted(rest, [])
    ["`", ..rest] -> parse_value_backtick_quoted(rest, [])
    ["#", ..rest] -> parse_comment(rest, fn(r) { parse_value(r) })
    [c, ..rest] -> parse_value_unquoted(rest, [c])
    [] -> Ok(#("", []))
  }
}

/// Parse an unquoted value from a list of characters
/// .env files allow unquoted values, but they must not contain whitespace or special characters
fn parse_value_unquoted(
  text: Chars,
  acc: Chars,
) -> Result(#(String, Chars), String) {
  case text {
    ["\n", ..rest] -> Ok(#(string.trim(join(acc)), rest))
    ["#", ..rest] -> parse_comment(rest, fn(r) { parse_value_unquoted(r, acc) })
    [c, ..rest] -> parse_value_unquoted(rest, [c, ..acc])
    [] -> Ok(#(string.trim(join(acc)), []))
  }
}

/// Parse a double-quoted value from a list of characters
fn parse_value_double_quoted(
  text: Chars,
  acc: Chars,
) -> Result(#(String, Chars), String) {
  case text {
    ["\"", ..rest] -> Ok(#(join(acc), rest))
    ["\\", "\"" as c, ..rest] -> parse_value_double_quoted(rest, [c, ..acc])
    ["\\", "n", ..rest] -> parse_value_double_quoted(rest, ["\n", ..acc])
    [c, ..rest] -> parse_value_double_quoted(rest, [c, ..acc])
    [] -> Error("unclosed double quote")
  }
}

/// Parse a single-quoted value from a list of characters
fn parse_value_single_quoted(
  text: Chars,
  acc: Chars,
) -> Result(#(String, Chars), String) {
  case text {
    ["'", ..rest] -> Ok(#(join(acc), rest))
    ["\\", "'" as c, ..rest] -> parse_value_single_quoted(rest, [c, ..acc])
    [c, ..rest] -> parse_value_single_quoted(rest, [c, ..acc])
    [] -> Error("unclosed single quote")
  }
}

/// Parse a backtick-quoted value from a list of characters
fn parse_value_backtick_quoted(
  text: Chars,
  acc: Chars,
) -> Result(#(String, Chars), String) {
  case text {
    ["`", ..rest] -> Ok(#(join(acc), rest))
    ["\\", "`" as char, ..rest] ->
      parse_value_backtick_quoted(rest, [char, ..acc])
    [char, ..rest] -> parse_value_backtick_quoted(rest, [char, ..acc])
    [] -> Error("unclosed backtick quote")
  }
}

/// Parse a comment from a list of characters
fn parse_comment(text: Chars, next: fn(Chars) -> a) -> a {
  case text {
    ["\n", ..] -> next(text)
    [_, ..rest] -> parse_comment(rest, next)
    [] -> next(text)
  }
}

/// Join a list of strings into a single string
/// The list is reversed before joining because the characters are accumulated in reverse order during parsing
fn join(strings: List(String)) -> String {
  strings |> list.reverse |> string.join("")
}

// On Windows, the line endings are \r\n, but we want to unify them to \n because `string.to_graphemes` will not split `\r\n` into separate characters on Windows it seems
// Yes, we could pattern match on `\r\n` and `\n` in `parse_kvs`, but this is a safer solution rather than depending on what could be unknown/platform-specific behaviour at times
// as proven with the earlier version of this parser written under the assumption that `\r\n` would be split into separate characters, we can just do that find and replace here once and for all
fn explode_to_graphemes(text: String) -> Chars {
  string.replace(text, "\r\n", "\n")
  |> string.to_graphemes
}
