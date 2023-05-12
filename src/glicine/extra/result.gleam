//// This module exposes additional functions to work with results.
////

import gleam/list
import gleam/result

/// TODO
pub fn try(
  result: Result(a, e),
  map_error map: fn(e) -> e1,
  continue_with fun: fn(a) -> Result(b, e1),
) -> Result(b, e1) {
  result
  |> result.map_error(map)
  |> result.try(fun)
}

pub fn on_error(
  after result: fn() -> Result(a, e),
  do action: fn(e) -> Nil,
) -> Result(Nil, e) {
  result()
  |> result.replace(Nil)
  |> result.map_error(fn(e) {
    action(e)
    e
  })
}

/// See [this PR](https://github.com/gleam-lang/stdlib/pull/449).
/// TODO: use the stdlib function once the PR is merged.
///
pub fn partition(results: List(Result(a, b))) -> Result(List(a), List(b)) {
  case results {
    [] -> Ok([])
    [Ok(a), ..rest] -> do_partition(rest, Ok([a]))
    [Error(b), ..rest] -> do_partition(rest, Error([b]))
  }
}

fn do_partition(results: List(Result(a, b)), acc: Result(List(a), List(b))) {
  case results {
    [] ->
      acc
      |> result.map(list.reverse)
      |> result.map_error(list.reverse)

    [Ok(a), ..rest] ->
      case acc {
        Ok(all_as) -> do_partition(rest, Ok([a, ..all_as]))
        Error(all_bs) -> do_partition(rest, Error(all_bs))
      }

    [Error(b), ..rest] ->
      case acc {
        Ok(_) -> do_partition(rest, Error([b]))
        Error(all_bs) -> do_partition(rest, Error([b, ..all_bs]))
      }
  }
}
