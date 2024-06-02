import { Error as GleamError, Ok as GleamOk } from "./gleam.mjs";

const Nil = undefined;

/**
 * @param {string} key
 * @param {string} value
 * @returns {GleamError | GleamOk}
 */
export function set_env(key, value) {
  // Ensure we can even run in this runtime
  const runtime = get_runtime();
  if (runtime == "unknown") {
    return new GleamError("unknown runtime");
  }

  // Ensure we have a non-empty key and a non-null/empty value
  key = key?.trim();
  if (!key) return GleamError("key is required");
  if (value === undefined || value === null) {
    // A blank string counts as a value in this case, useful for situations where the user explicitly wants to override an env var with an empty string
    return new GleamError("value is required for key: " + key);
  }

  if (runtime == "node" || runtime == "bun") {
    process.env[key?.trim()] = value;
  } else if (runtime == "deno") {
    Deno.env.set(key?.trim(), value);
  } else {
    return new GleamError("unsupported runtime: " + runtime);
  }

  return new GleamOk(Nil);
}

/**
 * @param {string} key
 * @param {string} value
 * @returns {GleamError | GleamOk}
 */
export function get_env(key) {
  const runtime = get_runtime();
  if (runtime == "unknown") {
    return new GleamError("unknown runtime");
  }

  key = key?.trim();
  if (!key) return new GleamError("key is required");

  let value = Nil;

  switch (runtime) {
    case "node":
    case "bun":
      value = process?.env[key];
      break;
    case "deno":
      value = Deno.env.get(key);
      break;
    default:
      return new GleamError("unsupported runtime: " + runtime);
  }

  if (value == Nil || value === undefined) {
    return new GleamError(Nil);
  }

  return new GleamOk(value);
}

/**
 * @returns {"node" | "deno" | "bun" | "browser" | "unknown"}
 */
function get_runtime() {
  if (typeof process !== "undefined") {
    return "node";
  }

  if (typeof Deno !== "undefined") {
    return "deno";
  }

  if (typeof Bun !== "undefined") {
    return "bun";
  }

  if (typeof window !== "undefined") {
    return "browser";
  }

  return "unknown";
}
