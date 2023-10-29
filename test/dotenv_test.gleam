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

  os.get_env("BASIC")
  |> should.equal(Ok("basic"))

  os.get_env("AFTER_LINE")
  |> should.equal(Ok("after_line"))

  os.get_env("EMPTY")
  |> should.equal(Ok(""))

  os.get_env("EMPTY_SINGLE_QUOTES")
  |> should.equal(Ok(""))

  os.get_env("EMPTY_DOUBLE_QUOTES")
  |> should.equal(Ok(""))

  os.get_env("SINGLE_QUOTES")
  |> should.equal(Ok("single_quotes"))

  os.get_env("SINGLE_QUOTES_SPACED")
  |> should.equal(Ok("    single quotes    "))

  os.get_env("DOUBLE_QUOTES_INSIDE_SINGLE")
  |> should.equal(Ok("double \"quotes\" work inside single quotes"))

  os.get_env("DOUBLE_QUOTES_WITH_NO_SPACE_BRACKET")
  |> should.equal(Ok("{ port: $MONGOLAB_PORT}"))

  os.get_env("SINGLE_QUOTES_INSIDE_DOUBLE")
  |> should.equal(Ok("single 'quotes' work inside double quotes"))

  os.get_env("BACKTICKS_INSIDE_SINGLE")
  |> should.equal(Ok("`backticks` work inside single quotes"))

  os.get_env("BACKTICKS_INSIDE_DOUBLE")
  |> should.equal(Ok("`backticks` work inside double quotes"))

  os.get_env("BACKTICKS")
  |> should.equal(Ok("backticks"))

  os.get_env("BACKTICKS_SPACED")
  |> should.equal(Ok("    backticks    "))

  os.get_env("DOUBLE_QUOTES_INSIDE_BACKTICKS")
  |> should.equal(Ok("double \"quotes\" work inside backticks"))

  os.get_env("SINGLE_QUOTES_INSIDE_BACKTICKS")
  |> should.equal(Ok("single 'quotes' work inside backticks"))

  os.get_env("DOUBLE_AND_SINGLE_QUOTES_INSIDE_BACKTICKS")
  |> should.equal(Ok(
    "double \"quotes\" and single 'quotes' work inside backticks",
  ))

  os.get_env("EXPAND_NEWLINES")
  |> should.equal(Ok("expand\nnew\nlines"))

  os.get_env("DONT_EXPAND_UNQUOTED")
  |> should.equal(Ok("dontexpand\\nnewlines"))

  os.get_env("DONT_EXPAND_SQUOTED")
  |> should.equal(Ok("dontexpand\\nnewlines"))

  os.get_env("INLINE_COMMENTS")
  |> should.equal(Ok("inline comments"))

  os.get_env("INLINE_COMMENTS_SINGLE_QUOTES")
  |> should.equal(Ok("inline comments outside of #singlequotes"))

  os.get_env("INLINE_COMMENTS_DOUBLE_QUOTES")
  |> should.equal(Ok("inline comments outside of #doublequotes"))

  os.get_env("INLINE_COMMENTS_BACKTICKS")
  |> should.equal(Ok("inline comments outside of #backticks"))

  os.get_env("INLINE_COMMENTS_SPACE")
  |> should.equal(Ok("inline comments start with a"))

  os.get_env("EQUAL_SIGNS")
  |> should.equal(Ok("equals=="))

  os.get_env("RETAIN_INNER_QUOTES")
  |> should.equal(Ok("{\"foo\": \"bar\"}"))

  os.get_env("RETAIN_INNER_QUOTES_AS_STRING")
  |> should.equal(Ok("{\"foo\": \"bar\"}"))

  os.get_env("RETAIN_INNER_QUOTES_AS_BACKTICKS")
  |> should.equal(Ok("{\"foo\": \"bar's\"}"))

  os.get_env("TRIM_SPACE_FROM_UNQUOTED")
  |> should.equal(Ok("some spaced out string"))

  os.get_env("USERNAME")
  |> should.equal(Ok("therealnerdybeast@example.tld"))

  os.get_env("SPACED_KEY")
  |> should.equal(Ok("parsed"))
}

pub fn load_multiline_test() {
  dotenv.load_with_opts(Opts(
    path: ".env.multiline",
    debug: True,
    capitalize: True,
  ))

  os.get_env("BASIC")
  |> should.equal(Ok("basic"))

  os.get_env("AFTER_LINE")
  |> should.equal(Ok("after_line"))

  os.get_env("EMPTY")
  |> should.equal(Ok(""))

  os.get_env("SINGLE_QUOTES")
  |> should.equal(Ok("single_quotes"))

  os.get_env("SINGLE_QUOTES_SPACED")
  |> should.equal(Ok("    single quotes    "))

  os.get_env("DOUBLE_QUOTES")
  |> should.equal(Ok("double_quotes"))

  os.get_env("DOUBLE_QUOTES_SPACED")
  |> should.equal(Ok("    double quotes    "))

  os.get_env("EXPAND_NEWLINES")
  |> should.equal(Ok("expand\nnew\nlines"))

  os.get_env("DONT_EXPAND_UNQUOTED")
  |> should.equal(Ok("dontexpand\\nnewlines"))

  os.get_env("DONT_EXPAND_SQUOTED")
  |> should.equal(Ok("dontexpand\\nnewlines"))

  os.get_env("EQUAL_SIGNS")
  |> should.equal(Ok("equals=="))

  os.get_env("RETAIN_INNER_QUOTES")
  |> should.equal(Ok("{\"foo\": \"bar\"}"))

  os.get_env("RETAIN_INNER_QUOTES_AS_STRING")
  |> should.equal(Ok("{\"foo\": \"bar\"}"))

  os.get_env("TRIM_SPACE_FROM_UNQUOTED")
  |> should.equal(Ok("some spaced out string"))

  os.get_env("USERNAME")
  |> should.equal(Ok("therealnerdybeast@example.tld"))

  os.get_env("SPACED_KEY")
  |> should.equal(Ok("parsed"))

  os.get_env("MULTI_DOUBLE_QUOTED")
  |> should.equal(Ok("THIS\nIS\nA\nMULTILINE\nSTRING"))

  // os.get_env("MULTI_SINGLE_QUOTED")
  // |> should.equal(Ok("THIS\nIS\nA\nMULTILINE\nSTRING"))

  os.get_env("MULTI_BACKTICKED")
  |> should.equal(Ok("THIS\nIS\nA\n\"MULTILINE'S\"\nSTRING"))
}
