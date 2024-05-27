import { Ok as GleamOk, Error as GleamError } from "./gleam.mjs";

// TODO: support bun and deno
export function set_env(key, value) {
	const runtime = get_runtime();
	if (runtime == "browser")
		return GleamError("dotenv is not supported in browser");
	if (runtime == "unknown") return GleamError("unknown runtime");

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
