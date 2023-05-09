//// This module exposes some utility functions used by other glicine modules.
////

import gleam/string
import gleam/list
import gleam/result
import gleam/function
import gleam/map
import gleam/erlang/file
import glicine/types.{Keep}
import glicine/utils/path

/// Like `list.filter` but uses a `filter` that returns `Keep` instead
/// of a `Bool` value.
///
pub fn list_keep(from list: List(a), with filter: fn(a) -> Keep) {
  list
  |> list.filter(fn(a) { filter(a) == Keep })
}

/// Tests if a file name has the `.md` extension.
///
pub fn is_markdown(file: String) -> Bool {
  string.ends_with(file, ".md")
}

/// See [this PR](https://github.com/gleam-lang/stdlib/pull/449).
/// TODO: use the stdlib function once the PR is merged.
///
pub fn result_partition(results: List(Result(a, b))) -> Result(List(a), List(b)) {
  case results {
    [] -> Ok([])
    [Ok(a), ..rest] -> do_result_partition(rest, Ok([a]))
    [Error(b), ..rest] -> do_result_partition(rest, Error([b]))
  }
}

fn do_result_partition(
  results: List(Result(a, b)),
  acc: Result(List(a), List(b)),
) {
  case results {
    [] ->
      acc
      |> result.map(list.reverse)
      |> result.map_error(list.reverse)

    [Ok(a), ..rest] ->
      case acc {
        Ok(all_as) -> do_result_partition(rest, Ok([a, ..all_as]))
        Error(all_bs) -> do_result_partition(rest, Error(all_bs))
      }

    [Error(b), ..rest] ->
      case acc {
        Ok(_) -> do_result_partition(rest, Error([b]))
        Error(all_bs) -> do_result_partition(rest, Error([b, ..all_bs]))
      }
  }
}

/// Given a list of elements returns a list containing only the
/// elements that appear more than once
///
pub fn duplicates(in list: List(a)) -> List(a) {
  let grouped = list.group(list, function.identity)
  use acc, elem, duplicates <- map.fold(over: grouped, from: [])
  case duplicates {
    [] | [_] -> acc
    [_, ..] -> [elem, ..acc]
  }
}

/// Tries to create a directory and all missing parent directories.
/// TODO: FIXME: currently only works with unix-style separator "/"
///
pub fn make_directory(path: String) -> Result(Nil, file.Reason) {
  case string.split(path, on: "/") {
    [] -> Error(file.Enoent)
    [base, ..dirs] -> {
      [base, ..list.scan(dirs, from: base, with: path.concat)]
      |> list.try_map(try_make_directory)
      |> result.replace(Nil)
    }
  }
}

fn try_make_directory(directory) -> Result(Nil, file.Reason) {
  case file.is_directory(directory) {
    True -> Ok(Nil)
    False -> file.make_directory(directory)
  }
}

/// Perform a side effect if the result is `Ok` and leave it unchanged.
/// Useful to perform reporting in a pipeline of results.
///
pub fn if_ok_do(result: Result(a, e), action: fn(a) -> Nil) -> Result(a, e) {
  use a <- result.map(result)
  action(a)
  a
}

/// Perform a side effect if the result is `Error` and leave it unchanged.
/// Useful to perform reporting in a pipeline of results.
///
pub fn if_error_do(result: Result(a, e), action: fn(e) -> Nil) -> Result(a, e) {
  use e <- result.map_error(result)
  action(e)
  e
}

/// Used to select the plural or singular form based on a number.
///
pub fn pick_form(n: Int, singular: String, plural: String) -> String {
  case n {
    1 -> singular
    _ -> plural
  }
}
