//// This module exposes some utility functions used by other glicine modules.
////

import gleam/string
import gleam/list
import gleam/result
import glicine/types.{Keep}

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
