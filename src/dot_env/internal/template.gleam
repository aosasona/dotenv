import dot_env/env
import gleam/dict
import gleam/list
import gleam/string

pub fn missing_keys(
  config: List(#(String, String)),
  config_example: List(#(String, String)),
  capitalize: Bool,
) -> List(String) {
  let config_dict = dict.from_list(config)

  list.fold(config_example, [], fn(acc, kv) {
    let #(key, _) = kv

    let look_up_key = case capitalize {
      True -> string.uppercase(key)
      False -> key
    }

    let is_set = has_env(look_up_key) || dict.has_key(config_dict, key)
    case is_set {
      True -> acc
      False -> [key, ..acc]
    }
  })
  |> list.reverse
}

fn has_env(key: String) -> Bool {
  case env.get_string(key) {
    Ok(_) -> True
    Error(_) -> False
  }
}
