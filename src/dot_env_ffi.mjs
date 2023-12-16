import { Ok as GleamOk, Error as GleamError } from "./gleam.mjs";

const Nil = undefined;

export function set_env(key, value) {
  if (!process.env) {
    console.error("process.env is not available");
    return Nil;
  }

  process.env[key] = value;
  return Nil;
}

export function get_env(key) {
  if (!process.env) {
    console.error("process.env is not available");
    return new GleamError("process.env is not available");
  }

  const value = process.env[key];
  if (!value) {
    return new GleamError(`key \`${key}\` is not set`);
  }

  return new GleamOk(value);
}
