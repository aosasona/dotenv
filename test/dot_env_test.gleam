import dot_env.{Opts}
import dot_env/env
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn get_test() {
  dot_env.load()

  env.get_or("UNDEFINED_KEY", "default")
  |> should.equal("default")

  env.get_int("PORT")
  |> should.equal(Ok(9000))

  env.get_bool("APP_DEBUG")
  |> should.equal(Ok(True))
}

pub fn load_missing_env_file_test() {
  env.set("PORT", "9000")

  // This should not fail or crash
  dot_env.load_with_opts(Opts(
    path: ".definitely_not_a_real_file",
    debug: True,
    capitalize: True,
    ignore_missing_file: True,
  ))

  env.get("PORT")
  |> should.equal(Ok("9000"))
}

pub fn load_default_test() {
  dot_env.load()

  env.get("PORT")
  |> should.equal(Ok("9000"))

  env.get("APP_NAME")
  |> should.equal(Ok("app"))

  env.get("APP_ENV")
  |> should.equal(Ok("local"))

  env.get("APP_KEY")
  |> should.equal(Ok("base-64:0"))

  env.get("APP_DEBUG")
  |> should.equal(Ok("true"))
}

pub fn load_normal_test() {
  dot_env.load_with_opts(Opts(
    path: ".env.normal",
    debug: True,
    capitalize: True,
    ignore_missing_file: False,
  ))

  env.get("BASIC")
  |> should.equal(Ok("basic"))

  env.get("AFTER_LINE")
  |> should.equal(Ok("after_line"))

  env.get("EMPTY")
  |> should.equal(Ok(""))

  env.get("EMPTY_SINGLE_QUOTES")
  |> should.equal(Ok(""))

  env.get("EMPTY_DOUBLE_QUOTES")
  |> should.equal(Ok(""))

  env.get("SINGLE_QUOTES")
  |> should.equal(Ok("single_quotes"))

  env.get("SINGLE_QUOTES_SPACED")
  |> should.equal(Ok("    single quotes    "))

  env.get("DOUBLE_QUOTES_INSIDE_SINGLE")
  |> should.equal(Ok("double \"quotes\" work inside single quotes"))

  env.get("DOUBLE_QUOTES_WITH_NO_SPACE_BRACKET")
  |> should.equal(Ok("{ port: $MONGOLAB_PORT}"))

  env.get("SINGLE_QUOTES_INSIDE_DOUBLE")
  |> should.equal(Ok("single 'quotes' work inside double quotes"))

  env.get("BACKTICKS_INSIDE_SINGLE")
  |> should.equal(Ok("`backticks` work inside single quotes"))

  env.get("BACKTICKS_INSIDE_DOUBLE")
  |> should.equal(Ok("`backticks` work inside double quotes"))

  env.get("BACKTICKS")
  |> should.equal(Ok("backticks"))

  env.get("BACKTICKS_SPACED")
  |> should.equal(Ok("    backticks    "))

  env.get("DOUBLE_QUOTES_INSIDE_BACKTICKS")
  |> should.equal(Ok("double \"quotes\" work inside backticks"))

  env.get("SINGLE_QUOTES_INSIDE_BACKTICKS")
  |> should.equal(Ok("single 'quotes' work inside backticks"))

  env.get("DOUBLE_AND_SINGLE_QUOTES_INSIDE_BACKTICKS")
  |> should.equal(Ok(
    "double \"quotes\" and single 'quotes' work inside backticks",
  ))

  env.get("EXPAND_NEWLINES")
  |> should.equal(Ok("expand\nnew\nlines"))

  env.get("DONT_EXPAND_UNQUOTED")
  |> should.equal(Ok("dontexpand\\nnewlines"))

  env.get("DONT_EXPAND_SQUOTED")
  |> should.equal(Ok("dontexpand\\nnewlines"))

  env.get("INLINE_COMMENTS")
  |> should.equal(Ok("inline comments"))

  env.get("INLINE_COMMENTS_SINGLE_QUOTES")
  |> should.equal(Ok("inline comments outside of #singlequotes"))

  env.get("INLINE_COMMENTS_DOUBLE_QUOTES")
  |> should.equal(Ok("inline comments outside of #doublequotes"))

  env.get("INLINE_COMMENTS_BACKTICKS")
  |> should.equal(Ok("inline comments outside of #backticks"))

  env.get("INLINE_COMMENTS_SPACE")
  |> should.equal(Ok("inline comments start with a"))

  env.get("EQUAL_SIGNS")
  |> should.equal(Ok("equals=="))

  env.get("RETAIN_INNER_QUOTES")
  |> should.equal(Ok("{\"foo\": \"bar\"}"))

  env.get("RETAIN_INNER_QUOTES_AS_STRING")
  |> should.equal(Ok("{\"foo\": \"bar\"}"))

  env.get("RETAIN_INNER_QUOTES_AS_BACKTICKS")
  |> should.equal(Ok("{\"foo\": \"bar's\"}"))

  env.get("TRIM_SPACE_FROM_UNQUOTED")
  |> should.equal(Ok("some spaced out string"))

  env.get("USERNAME")
  |> should.equal(Ok("therealnerdybeast@example.tld"))

  env.get("SPACED_KEY")
  |> should.equal(Ok("parsed"))

  env.get("DOESNT_EXIST")
  |> should.equal(Error("key DOESNT_EXIST is not set"))
}

pub fn load_multiline_test() {
  dot_env.load_with_opts(Opts(
    path: ".env.multiline",
    debug: True,
    capitalize: True,
    ignore_missing_file: False,
  ))

  env.get("BASIC")
  |> should.equal(Ok("basic"))

  env.get("AFTER_LINE")
  |> should.equal(Ok("after_line"))

  env.get("EMPTY")
  |> should.equal(Ok(""))

  env.get("SINGLE_QUOTES")
  |> should.equal(Ok("single_quotes"))

  env.get("SINGLE_QUOTES_SPACED")
  |> should.equal(Ok("    single quotes    "))

  env.get("DOUBLE_QUOTES")
  |> should.equal(Ok("double_quotes"))

  env.get("DOUBLE_QUOTES_SPACED")
  |> should.equal(Ok("    double quotes    "))

  env.get("EXPAND_NEWLINES")
  |> should.equal(Ok("expand\nnew\nlines"))

  env.get("DONT_EXPAND_UNQUOTED")
  |> should.equal(Ok("dontexpand\\nnewlines"))

  env.get("DONT_EXPAND_SQUOTED")
  |> should.equal(Ok("dontexpand\\nnewlines"))

  env.get("EQUAL_SIGNS")
  |> should.equal(Ok("equals=="))

  env.get("RETAIN_INNER_QUOTES")
  |> should.equal(Ok("{\"foo\": \"bar\"}"))

  env.get("RETAIN_INNER_QUOTES_AS_STRING")
  |> should.equal(Ok("{\"foo\": \"bar\"}"))

  env.get("TRIM_SPACE_FROM_UNQUOTED")
  |> should.equal(Ok("some spaced out string"))

  env.get("USERNAME")
  |> should.equal(Ok("therealnerdybeast@example.tld"))

  env.get("SPACED_KEY")
  |> should.equal(Ok("parsed"))

  env.get("MULTI_DOUBLE_QUOTED")
  |> should.equal(Ok("THIS\nIS\nA\nMULTILINE\nSTRING"))

  // Currently failing i.e. not supported
  // env.get("MULTI_SINGLE_QUOTED")
  // |> should.equal(Ok("THIS\nIS\nA\nMULTILINE\nSTRING"))

  env.get("MULTI_BACKTICKED")
  |> should.equal(Ok("THIS\nIS\nA\n\"MULTILINE'S\"\nSTRING"))
}
