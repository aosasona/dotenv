import gleam/string
import gleam/list
import gleam/queue.{Queue}
import gleam/regex

const line_regex = "(?:^|^)\\s*(?:export\\s+)?([\\w.-]+)(?:\\s*=\\s*?|:\\s+?)(\\s*'(?:\\\\'|[^'])*'|\\s*\"(?:\\\\\"|[^\"])*\"|\\s*`(?:\\\\`|[^`])*`|[^#\\r\\n]+)?\\s*(?:#.*)?(?:$|$)"

pub type EnvPairs =
  List(#(String, String))

pub fn parse(text: String) -> Result(EnvPairs, String) {
  let lines = replace(text, "\r\n?", with: "\n")
  let env_map =
    lines_to_list(lines)
    |> queue.from_list
    |> pop_first_if_empty
    |> pop_last_if_empty
    |> queue.to_list
    |> to_pairs([])

  Ok(env_map)
}

fn to_pairs(raw_list: List(String), state: EnvPairs) -> EnvPairs {
  case raw_list {
    [key, value, ..rest] -> {
      case is_valid_key(key) {
        True -> to_pairs(rest, list.concat([state, [#(key, value)]]))
        False -> to_pairs(rest, state)
      }
    }
    [key] -> {
      case is_valid_key(key) {
        True -> list.concat([state, [#(key, "")]])
        False -> state
      }
    }
    // MAYBE: there might be other patterns that are valid, but I'm not sure what they are at the moment
    [] | _ -> state
  }
}

fn pop_first_if_empty(items: Queue(String)) -> Queue(String) {
  case queue.pop_front(items) {
    Ok(#(first, _)) -> {
      case first {
        "" -> {
          case queue.pop_front(items) {
            Ok(#(_, rest)) -> rest
            Error(_) -> items
          }
        }
        _ -> items
      }
    }
    Error(_) -> items
  }
}

fn pop_last_if_empty(items: Queue(String)) -> Queue(String) {
  case queue.pop_back(items) {
    Ok(#(last, _)) -> {
      case last {
        "" -> {
          case queue.pop_back(items) {
            Ok(#(_, rest)) -> rest
            Error(_) -> items
          }
        }
        _ -> items
      }
    }
    Error(_) -> items
  }
}

fn is_valid_key(key: String) -> Bool {
  case
    regex.compile(
      "^[a-zA-Z_]+[a-zA-Z0-9_]*$",
      regex.Options(case_insensitive: True, multi_line: True),
    )
  {
    Ok(re) -> regex.check(with: re, content: key)
    Error(_) -> False
  }
}

fn lines_to_list(text: String) -> List(String) {
  case
    regex.compile(
      line_regex,
      regex.Options(case_insensitive: True, multi_line: True),
    )
  {
    Ok(re) -> regex.split(with: re, content: text)
    Error(_) -> []
  }
  |> list.filter(fn(line) { line != "\n" })
}

// replace parts of string with a regex - the standard library doesn't have this yet
fn replace(
  string str: String,
  pattern regex: String,
  with with: String,
) -> String {
  case
    regex.compile(
      regex,
      regex.Options(case_insensitive: True, multi_line: True),
    )
  {
    Ok(re) ->
      regex.split(with: re, content: str)
      |> string.join(with)
      |> string.trim
    Error(_) -> str
  }
}
