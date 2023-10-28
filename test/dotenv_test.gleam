import dotenv.{Opts}
import gleam/erlang/os
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn load_default_test() {
  dotenv.load()

  os.get_env("PORT")
  |> should.equal(Ok("9000"))

  os.get_env("APP_NAME")
  |> should.equal(Ok("app"))

  os.get_env("APP_ENV")
  |> should.equal(Ok("local"))

  os.get_env("APP_KEY")
  |> should.equal(Ok("base-64:0"))

  os.get_env("APP_DEBUG")
  |> should.equal(Ok("true"))
}

pub fn load_normal_test() {
  dotenv.load_with_opts(Opts(path: ".env.normal", debug: True, capitalize: True))
  |> should.be_ok

  os.get_env("BASIC")
  |> should.equal(Ok("basic"))
}
