//// This module exposes additional functions used to work with directories.
////

import gleam/erlang/file
import glicine/extra/path
import gleam/list
import gleam/result
import gleam/string

/// Tries to create a directory and all missing parent directories.
/// TODO: FIXME: currently only works with unix-style separator "/"
///
pub fn make(path: String) -> Result(Nil, file.Reason) {
  case string.split(path, on: "/") {
    [] -> Error(file.Enoent)
    [base, ..dirs] -> {
      [base, ..list.scan(dirs, from: base, with: path.concat)]
      |> list.try_map(try_make)
      |> result.replace(Nil)
    }
  }
}

fn try_make(directory) -> Result(Nil, file.Reason) {
  case file.is_directory(directory) {
    Ok(True) -> Ok(Nil)
    Ok(False) -> file.make_directory(directory)
    Error(reason) -> Error(reason)
  }
}
