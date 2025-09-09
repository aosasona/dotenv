# dot_env

<!--toc:start-->

- [Quick start](#quick-start)
- [Installation](#installation)
<!--toc:end-->

[![Package Version](https://img.shields.io/hexpm/v/dot_env)](https://hex.pm/packages/dot_env)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/dot_env/)

dot_env is a port of the popular JavaScript [dotenv](https://github.com/motdotla/dotenv) package that helps you load environment variables from .env (or other) files.

> This package may support other formats in the future but for now, supports the popular .env format
>
> You can find the Javascript "tests" [here](https://github.com/aosasona/dot_js_test)

## Quick start

```gleam
import dot_env as dot
import dot_env/env
import dot_env/internal/example_validator
import gleam/io

pub fn main() {
  dot.new()
  |> dot.set_path("path/to/.env")
  |> dot.set_debug(False)
  |> dot.load

  // or dot_env.load_with_opts(dot_env.Opts(path: "path/to/.env", debug: False, capitalize: False))
  // or `dot_env.load_default()` to load the `.env` file in the root path

  case env.get_string("MY_ENV_VAR") {
    Ok(value) -> io.println(value)
    Error(_) -> io.println("something went wrong")
  }

  let app_name = env.get_string_or("APP_NAME", "my app name")
  let port = env.get_int_or("PORT", 3000)
  let enable_signup = env.get_bool_or("ENABLE_SIGNUP", True)

  echo app_name
  echo port
  echo enable_signup

  Nil
}
```

## Example File Validation

The package now supports validating your environment files against example files (e.g., `.env.example`). This helps ensure that all required environment variables are defined and warns about missing or extra keys.

```gleam
import dot_env as dot
import dot_env/internal/example_validator

pub fn main() {
    let config = example_validator.ExampleFileConfig(
        path: ".env.example",
        warn_extra_keys: True,
        warn_missing_keys: True,
    )

    dot.new()
    |> dot.set_path(".env")
    |> dot.set_example_validation(config)
    |> dot.load

    Nil
}
```

You can also use it with the options-based approach:

```gleam
import dot_env
import dot_env/internal/example_validator

pub fn main() {
    let config = example_validator.ExampleFileConfig(
        path: ".env.example",
        warn_extra_keys: False,  // Only warn about missing keys
        warn_missing_keys: True,
    )

    dot_env.load_with_opts(dot_env.Opts(
        path: ".env",
        debug: True,
        capitalize: True,
        ignore_missing_file: False,
        example_validation: option.Some(config),
    ))

    Nil
}
```

## Installation

```sh
gleam add dot_env
```

and its documentation can be found at <https://hexdocs.pm/dot_env>.
