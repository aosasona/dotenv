import dot_env/env
import gleam/dict
import gleam/list
import gleam/string

pub fn missing_keys(
  conf: List(#(String, String)),
  conf_example: List(#(String, String)),
  capitalize: Bool,
) -> List(String) {
  let conf_dict = dict.from_list(conf)

  list.fold(conf_example, [], fn(acc, kv) {
    let #(key, _) = kv

    let look_up_key = case capitalize {
      True -> string.uppercase(key)
      False -> key
    }

    let is_set = has_env(look_up_key) || dict.has_key(conf_dict, key)
    case is_set {
      True -> acc
      False -> [key, ..acc]
    }
  })
  |> list.reverse
}

// Todo check in os env
fn has_env(key: String) -> Bool {
  case env.get_string(key) {
    Ok(_) -> True
    Error(_) -> False
  }
}
