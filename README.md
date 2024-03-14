# dot_env

<!--toc:start-->

- [dot_env](#dotenv)
  - [Quick start](#quick-start)
  - [Installation](#installation)
  <!--toc:end-->

[![Package Version](https://img.shields.io/hexpm/v/dot_env)](https://hex.pm/packages/dotenv)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/dot_env/)

dot_env is a port of the popular JavaScript [dotenv](https://github.com/motdotla/dotenv) package that helps you load environment variables from .env (or other) files.

> This package may support other formats in the future but for now, supports the popular .env format
>
> You can find the Javascript test [here](https://github.com/aosasona/dot_js_test)

## Quick start

```gleam
import dot_env
import dot_env/env
import gleam/io

pub fn main() {
    dot_env.load_with_opts(dot_env.Opts(path: "path/to/.env", debug: False, capitalize: False))
    // or `dot_env.load()` to load the `.env` file in the root path

    case env.get("MY_ENV_VAR") {
        Ok(value) -> io.println(value)
        Error(_) -> io.println("something went wrong")
    }

    Nil
}
```

## Installation

```sh
gleam add dot_env
```

and its documentation can be found at <https://hexdocs.pm/dot_env>.
