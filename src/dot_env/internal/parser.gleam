import gleam/bool
import gleam/string
import gleam/list
import gleam/option.{Some}
import gleam/queue.{type Queue}
import gleam/regex
import gleam/result.{try}

const line_regex = "(?:^|^)\\s*(?:export\\s+)?([\\w.-]+)(?:\\s*=\\s*?|:\\s+?)(\\s*'(?:\\\\'|[^'])*'|\\s*\"(?:\\\\\"|[^\"])*\"|\\s*`(?:\\\\`|[^`])*`|[^#\\r\\n]+)?\\s*(?:#.*)?(?:$|$)"

pub type EnvPairs =
  List(#(String, String))

pub fn parse(text: String) -> Result(EnvPairs, String) {
  let lines = replace(text, "\r\n?", with: "\n")
  use env_map <- try(
    lines_to_list(lines)
    |> queue.from_list
    |> pop_first_if_empty
    |> pop_last_if_empty
    |> queue.to_list
    |> to_pairs([]),
  )

  Ok(env_map)
}

fn to_pairs(raw_list: List(String), state: EnvPairs) -> Result(EnvPairs, String) {
  case raw_list {
    [key, value, ..rest] -> {
      case is_valid_key(key) {
        True -> {
          case normalize_value(value) {
            Ok(normalized_value) ->
              to_pairs(rest, list.concat([state, [#(key, normalized_value)]]))
            Error(e) -> Error(e)
          }
        }
        False -> to_pairs(rest, state)
      }
    }
    [key] -> {
      case is_valid_key(key) {
        True -> Ok(list.concat([state, [#(key, "")]]))
        False -> Ok(state)
      }
    }
    // MAYBE: there might be other patterns that are valid, but I'm not sure what they are at the moment
    [] | _ -> Ok(state)
  }
}

fn normalize_value(value: String) -> Result(String, String) {
  let has_double_quotes = string.starts_with(value, "\"")

  use value <- try(
    string.trim(value)
    // extract whatever is inside the quotes
    |> remove_surrounding_quotes,
  )

  // replace escaped new lines with actual new lines if it original value was quoted with double quotes
  case has_double_quotes {
    True -> expand_new_lines(value)
    False -> value
  }
  |> Ok
}

fn expand_new_lines(value: String) -> String {
  string.replace(value, "\\n", with: "\n")
  |> string.replace("\\r", with: "\r")
}

fn remove_surrounding_quotes(value: String) -> Result(String, String) {
  case
    regex.compile(
      "^(['\"`])([\\s\\S]*)\\1$",
      regex.Options(case_insensitive: True, multi_line: True),
    )
  {
    Ok(re) -> {
      case regex.scan(with: re, content: value) {
        [match] -> extract_value_from_match(match)
        [_, ..] -> Error("Multiple quotes found in value: " <> value)
        [] -> Ok(value)
      }
    }

    Error(_) ->
      Error(
        "Regex error at extract_within_quotes, this is a bug, please create an issue",
      )
  }
}

fn extract_value_from_match(match: regex.Match) -> Result(String, String) {
  list.at(match.submatches, 1)
  |> result.unwrap(Some(match.content))
  |> option.unwrap("")
  |> Ok
}

fn is_valid_key(key: String) -> Bool {
  case
    regex.compile(
      "^[a-zA-Z_]+[a-zA-Z0-9_]*$",
      regex.Options(case_insensitive: False, multi_line: True),
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
    regex.compile(regex, regex.Options(case_insensitive: True, multi_line: True),
    )
  {
    Ok(re) ->
      regex.split(with: re, content: str)
      |> string.join(with)
      |> string.trim
    Error(_) -> str
  }
}

fn pop_first_if_empty(items: Queue(String)) -> Queue(String) {
  case queue.pop_front(items) {
    Ok(#(first, _)) -> {
      use <- bool.guard(when: first != "", return: items)

      case queue.pop_front(items) {
        Ok(#(_, rest)) -> rest
        Error(_) -> items
      }
    }
    Error(_) -> items
  }
}

fn pop_last_if_empty(items: Queue(String)) -> Queue(String) {
  case queue.pop_back(items) {
    Ok(#(last, _)) -> {
      use <- bool.guard(when: last != "", return: items)

      case queue.pop_back(items) {
        Ok(#(_, rest)) -> rest
        Error(_) -> items
      }
    }
    Error(_) -> items
  }
}
