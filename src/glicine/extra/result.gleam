//// This module exposes additional functions to work with results.
////

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

/// Turn the result of `result.partition` back into a single result.
/// If there's one or more errors it returns an Error with those.
/// If there's no errors then an Ok with the results is returned.
///
pub fn from_partition(pair: #(List(a), List(e))) -> Result(List(a), List(e)) {
  let #(results, errors) = pair
  case errors {
    [] -> Ok(results)
    _ -> Error(errors)
  }
}
