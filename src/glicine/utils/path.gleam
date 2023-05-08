//// This module exposes some utility functions used to work with unix-like
//// paths.
////

import gleam/string

/// Used to concatenate two strings in a unix-style path.
/// Ignores any string that is empty or only made of whitespace.
///
/// # Examples
/// ```gleam
/// "."
/// |> concat("path")
/// |> concat("    ")
/// |> concat("to")
/// |> concat("\n")
/// |> concat("dir")
/// > "./path/to/dir"
/// ```
///
pub fn concat(base path: String, other name: String) -> String {
  let trimmed_path = string.trim(path)
  let trimmed_name = string.trim(name)
  case trimmed_path, trimmed_name {
    "", "" -> ""
    _, "" -> trimmed_path
    "", _ -> trimmed_name
    _, _ -> trimmed_path <> "/" <> trimmed_name
  }
}
