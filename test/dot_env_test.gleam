import dot_env.{Opts}
import dot_env/env
import dot_env/internal/example_validator
import gleam/option
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn get_test() {
  dot_env.load_default()

  env.get_string("DEFINITELY_NOT_A_REAL_KEY")
  |> should.be_error

  env.get_string("PORT")
  |> should.equal(Ok("9000"))

  env.get_string_or("UNDEFINED_KEY", "default")
  |> should.equal("default")

  env.get_int("PORT")
  |> should.equal(Ok(9000))

  env.get_bool("APP_DEBUG")
  |> should.equal(Ok(True))

  env.get_int_or("PORT", 3000)
  |> should.equal(9000)

  env.get_bool_or("APP_DEBUG", False)
  |> should.equal(True)

  env.get_bool("PORT")
  |> should.be_error

  env.get_int("APP_DEBUG")
  |> should.be_error
}

pub fn load_missing_env_file_test() {
  let assert Ok(Nil) = env.set("PORT", "9000")

  // This should not fail or crash
  dot_env.load_with_opts(Opts(
    path: ".definitely_not_a_real_file",
    debug: True,
    capitalize: True,
    ignore_missing_file: True,
    example_validation: option.None,
  ))

  env.get_string("PORT")
  |> should.equal(Ok("9000"))
}

pub fn load_default_test() {
  dot_env.load_default()

  env.get_string("PORT")
  |> should.equal(Ok("9000"))

  env.get_string("APP_NAME")
  |> should.equal(Ok("app"))

  env.get_string("APP_ENV")
  |> should.equal(Ok("local"))

  env.get_string("APP_KEY")
  |> should.equal(Ok("base-64:0"))

  env.get_string("APP_DEBUG")
  |> should.equal(Ok("true"))

  env.get_string("APP_TIMEZONE")
  |> should.equal(Ok(""))

  env.get_string("APP_URL")
  |> should.equal(Ok("http://localhost"))
}

pub fn load_normal_test() {
  dot_env.load_with_opts(Opts(
    path: ".env.normal",
    debug: True,
    capitalize: True,
    ignore_missing_file: False,
    example_validation: option.None,
  ))

  env.get_string("BASIC")
  |> should.equal(Ok("basic"))

  env.get_string("AFTER_LINE")
  |> should.equal(Ok("after_line"))

  env.get_string("EMPTY")
  |> should.equal(Ok(""))

  env.get_string("EMPTY_SINGLE_QUOTES")
  |> should.equal(Ok(""))

  env.get_string("EMPTY_DOUBLE_QUOTES")
  |> should.equal(Ok(""))

  env.get_string("SINGLE_QUOTES")
  |> should.equal(Ok("single_quotes"))

  env.get_string("SINGLE_QUOTES_SPACED")
  |> should.equal(Ok("    single quotes    "))

  env.get_string("DOUBLE_QUOTES_INSIDE_SINGLE")
  |> should.equal(Ok("double \"quotes\" work inside single quotes"))

  env.get_string("DOUBLE_QUOTES_WITH_NO_SPACE_BRACKET")
  |> should.equal(Ok("{ port: $MONGOLAB_PORT}"))

  env.get_string("SINGLE_QUOTES_INSIDE_DOUBLE")
  |> should.equal(Ok("single 'quotes' work inside double quotes"))

  env.get_string("BACKTICKS_INSIDE_SINGLE")
  |> should.equal(Ok("`backticks` work inside single quotes"))

  env.get_string("BACKTICKS_INSIDE_DOUBLE")
  |> should.equal(Ok("`backticks` work inside double quotes"))

  env.get_string("BACKTICKS")
  |> should.equal(Ok("backticks"))

  env.get_string("BACKTICKS_SPACED")
  |> should.equal(Ok("    backticks    "))

  env.get_string("DOUBLE_QUOTES_INSIDE_BACKTICKS")
  |> should.equal(Ok("double \"quotes\" work inside backticks"))

  env.get_string("SINGLE_QUOTES_INSIDE_BACKTICKS")
  |> should.equal(Ok("single 'quotes' work inside backticks"))

  env.get_string("DOUBLE_AND_SINGLE_QUOTES_INSIDE_BACKTICKS")
  |> should.equal(Ok(
    "double \"quotes\" and single 'quotes' work inside backticks",
  ))

  env.get_string("EXPAND_NEWLINES")
  |> should.equal(Ok("expand\nnew\nlines"))

  env.get_string("DONT_EXPAND_UNQUOTED")
  |> should.equal(Ok("dontexpand\\nnewlines"))

  env.get_string("DONT_EXPAND_SQUOTED")
  |> should.equal(Ok("dontexpand\\nnewlines"))

  env.get_string("INLINE_COMMENTS")
  |> should.equal(Ok("inline comments"))

  env.get_string("INLINE_COMMENTS_SINGLE_QUOTES")
  |> should.equal(Ok("inline comments outside of #singlequotes"))

  env.get_string("INLINE_COMMENTS_DOUBLE_QUOTES")
  |> should.equal(Ok("inline comments outside of #doublequotes"))

  env.get_string("INLINE_COMMENTS_BACKTICKS")
  |> should.equal(Ok("inline comments outside of #backticks"))

  env.get_string("INLINE_COMMENTS_SPACE")
  |> should.equal(Ok("inline comments start with a"))

  env.get_string("EQUAL_SIGNS")
  |> should.equal(Ok("equals=="))

  env.get_string("RETAIN_INNER_QUOTES")
  |> should.equal(Ok("{\"foo\": \"bar\"}"))

  env.get_string("RETAIN_INNER_QUOTES_AS_STRING")
  |> should.equal(Ok("{\"foo\": \"bar\"}"))

  env.get_string("RETAIN_INNER_QUOTES_AS_BACKTICKS")
  |> should.equal(Ok("{\"foo\": \"bar's\"}"))

  env.get_string("TRIM_SPACE_FROM_UNQUOTED")
  |> should.equal(Ok("some spaced out string"))

  env.get_string("USERNAME")
  |> should.equal(Ok("therealnerdybeast@example.tld"))

  env.get_string("SPACED_KEY")
  |> should.equal(Ok("parsed"))

  env.get_string("DOESNT_EXIST")
  |> should.equal(Error("key DOESNT_EXIST is not set"))
}

pub fn load_multiline_test() {
  dot_env.load_with_opts(Opts(
    path: ".env.multiline",
    debug: True,
    capitalize: True,
    ignore_missing_file: False,
    example_validation: option.None,
  ))

  env.get_string("BASIC")
  |> should.equal(Ok("basic"))

  env.get_string("AFTER_LINE")
  |> should.equal(Ok("after_line"))

  env.get_string("EMPTY")
  |> should.equal(Ok(""))

  env.get_string("SINGLE_QUOTES")
  |> should.equal(Ok("single_quotes"))

  env.get_string("SINGLE_QUOTES_SPACED")
  |> should.equal(Ok("    single quotes    "))

  env.get_string("DOUBLE_QUOTES")
  |> should.equal(Ok("double_quotes"))

  env.get_string("DOUBLE_QUOTES_SPACED")
  |> should.equal(Ok("    double quotes    "))

  env.get_string("EXPAND_NEWLINES")
  |> should.equal(Ok("expand\nnew\nlines"))

  env.get_string("DONT_EXPAND_UNQUOTED")
  |> should.equal(Ok("dontexpand\\nnewlines"))

  env.get_string("DONT_EXPAND_SQUOTED")
  |> should.equal(Ok("dontexpand\\nnewlines"))

  env.get_string("EQUAL_SIGNS")
  |> should.equal(Ok("equals=="))

  env.get_string("RETAIN_INNER_QUOTES")
  |> should.equal(Ok("{\"foo\": \"bar\"}"))

  env.get_string("RETAIN_INNER_QUOTES_AS_STRING")
  |> should.equal(Ok("{\"foo\": \"bar\"}"))

  env.get_string("TRIM_SPACE_FROM_UNQUOTED")
  |> should.equal(Ok("some spaced out string"))

  env.get_string("USERNAME")
  |> should.equal(Ok("therealnerdybeast@example.tld"))

  env.get_string("SPACED_KEY")
  |> should.equal(Ok("parsed"))

  env.get_string("MULTI_DOUBLE_QUOTED")
  |> should.equal(Ok("THIS\nIS\nA\nMULTILINE\nSTRING"))

  env.get_string("MULTI_SINGLE_QUOTED")
  |> should.equal(Ok("THIS\nIS\nA\nMULTILINE\nSTRING"))

  env.get_string("MULTI_BACKTICKED")
  |> should.equal(Ok("THIS\nIS\nA\n\"MULTILINE'S\"\nSTRING"))
}

pub fn get_bool_test() {
  dot_env.load_with_opts(Opts(
    path: ".env.booleans",
    debug: True,
    capitalize: True,
    ignore_missing_file: False,
    example_validation: option.None,
  ))

  env.get_bool("BOOL_0")
  |> should.equal(Ok(False))

  env.get_bool("BOOL_1")
  |> should.equal(Ok(True))

  env.get_bool("BOOL_FALSE")
  |> should.equal(Ok(False))

  env.get_bool("BOOL_TRUE")
  |> should.equal(Ok(True))
}

pub fn example_file_validation_test() {
  // Test with example file validation enabled
  dot_env.load_with_opts(Opts(
    path: ".env",
    debug: True,
    capitalize: True,
    ignore_missing_file: False,
    example_validation: option.Some(example_validator.ExampleFileConfig(
      path: "test/env_example.txt",
      warn_extra_keys: True,
      warn_missing_keys: True,
    )),
  ))

  // The validation should have run and printed warnings
  // We can verify that the environment variables are still loaded correctly
  env.get_string("PORT")
  |> should.equal(Ok("9000"))

  env.get_string("APP_NAME")
  |> should.equal(Ok("app"))
}

pub fn example_file_validation_missing_file_test() {
  // Test with example file validation but file doesn't exist
  dot_env.load_with_opts(Opts(
    path: ".env",
    debug: True,
    capitalize: True,
    ignore_missing_file: False,
    example_validation: option.Some(example_validator.ExampleFileConfig(
      path: "test/nonexistent_example.txt",
      warn_extra_keys: True,
      warn_missing_keys: True,
    )),
  ))

  // Should still load the environment variables without errors
  env.get_string("PORT")
  |> should.equal(Ok("9000"))
}
