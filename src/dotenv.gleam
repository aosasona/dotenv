import gleam/io
import gleam/regex

pub type Opts {
  Opts(path: String, override_existing: Bool)
  Default
}

pub opaque type DotEnv {
  DotEnv(Opts)
}

pub fn load() {
  todo
}
