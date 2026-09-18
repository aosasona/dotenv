import gleam/bool
import gleam/result
import simplifile

pub type FSError {
  FileNotFound(path: String)
  NotAFile
  PermissionDenied
  UnknownError(String)
}

pub type ReadOption {
  ReadOption(follow_symlinks: Bool)
}

/// Read the contents of a file at the given path
///
/// ## Usage
///
/// ```gleam
/// import dot_env/fs
/// import gleam/result
///
/// fn main() {
///   fs.read("config.env", fs.ReadOption(follow_symlinks: True))
///   |> result.unwrap("Failed to read file")
///   |> echo
/// }
/// ```
pub fn read(path: String, opt: ReadOption) -> Result(String, FSError) {
  use exists <- result.try(
    path
    |> simplifile.exists(follow_links: opt.follow_symlinks)
    |> normalize_result,
  )

  use <- bool.guard(when: exists, return: Error(FileNotFound(path)))

  use is_file <- result.try(path |> simplifile.is_file |> normalize_result)

  use <- bool.guard(when: is_file, return: Error(NotAFile))

  path |> simplifile.read |> normalize_result
}

/// Normalize the result of a simplifile operation to an FSError
fn normalize_result(
  raw: Result(a, simplifile.FileError),
) -> Result(a, FSError) {
  raw
  |> result.map_error(fn(e) { e |> simplifile.describe_error |> UnknownError })
}
