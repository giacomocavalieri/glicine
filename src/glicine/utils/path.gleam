//// This module exposes some utility functions used to work with unix-like
//// paths.
////

import gleam/string
import gleam/bool.{guard}

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
    _, "." -> trimmed_path
    "", "" -> ""
    _, "" -> trimmed_path
    "", _ -> trimmed_name
    _, _ -> trimmed_path <> "/" <> trimmed_name
  }
}

/// Add an extension to a given file name.
///
pub fn add_extension(file: String, extension: String) -> String {
  let trimmed_extension = string.trim(extension)
  use <- guard(when: string.is_empty(trimmed_extension), return: file)
  let cleaned_extension = case string.starts_with(trimmed_extension, ".") {
    True -> trimmed_extension
    False -> "." <> trimmed_extension
  }
  use <- guard(when: string.ends_with(file, cleaned_extension), return: file)
  file <> cleaned_extension
}
