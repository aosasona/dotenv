-module(dot_env_ffi).

-export([get_env/1, set_env/2]).

get_env(Name) ->
  case os:getenv(binary_to_list(Name)) of
    false ->
      {error, list_to_binary(io_lib:format("key ~s is not set", [Name]))};
    Value ->
      {ok, list_to_binary(Value)}
  end.

set_env(Name, Value) ->
  os:putenv(binary_to_list(Name), binary_to_list(Value)),
  {ok, nil}.
