import gleam/list
import gleam/result.{try}
import gleam/string

pub type KVPair =
  #(String, String)

pub type KVPairs =
  List(KVPair)

type Chars =
  List(String)

pub fn parse(text: String) -> Result(KVPairs, String) {
  text
  |> explode_to_graphemes
  |> parse_kvs([])
}

fn parse_kvs(text: Chars, acc: KVPairs) -> Result(KVPairs, String) {
  case text {
    [] -> Ok(list.reverse(acc))
    ["\n", ..rest] | [" ", ..rest] -> parse_kvs(rest, acc)
    ["#", ..rest] -> parse_comment(rest, fn(r) { parse_kvs(r, acc) })
    ["e", "x", "p", "o", "r", "t", " ", ..rest] -> parse_kvs(rest, acc)
    _ -> {
      use #(pair, rest) <- try(parse_kv(text))
      parse_kvs(rest, [pair, ..acc])
    }
  }
}

fn parse_kv(text: Chars) -> Result(#(KVPair, Chars), String) {
  use #(key, rest) <- try(parse_key(text, []))
  use #(value, rest) <- try(parse_value(rest))
  Ok(#(#(key, value), rest))
}

fn parse_key(text: Chars, acc: Chars) -> Result(#(String, Chars), String) {
  case text {
    ["=", ..rest] -> Ok(#(string.trim(join(acc)), rest))
    [c, ..rest] -> parse_key(rest, [c, ..acc])
    [] -> Error("unexpected end of input")
  }
}

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

fn parse_comment(text: Chars, next: fn(Chars) -> a) -> a {
  case text {
    ["\n", ..] -> next(text)
    [_, ..rest] -> parse_comment(rest, next)
    [] -> next(text)
  }
}

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
