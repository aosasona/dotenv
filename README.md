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
import gleam/io

pub fn main() {
    dot.new()
    |> dot.set_path("path/to/.env")
    |> dot.set_debug(False)
    |> dot.load

    // or dot_env.load_with_opts(dot_env.Opts(path: "path/to/.env", debug: False, capitalize: False))
    // or `dot_env.load_default()` to load the `.env` file in the root path

    case env.get("MY_ENV_VAR") {
        Ok(value) -> io.println(value)
        Error(_) -> io.println("something went wrong")
    }

    let app_name = env.get_or("APP_NAME", "my app name")
    let port = env.get_int_or("PORT", 3000)
    let enable_signup = env.get_bool_or("ENABLE_SIGNUP", True)

    io.debug(app_name)
    io.debug(port)
    io.debug(enable_signup)

    Nil
}
```

## Installation

```sh
gleam add dot_env
```

and its documentation can be found at <https://hexdocs.pm/dot_env>.
