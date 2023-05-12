//// This module exposes additional functions used to work with lists. 
////

import gleam/function
import gleam/list
import gleam/map

/// It indicates wether an element should be kept or dropped from a list.
///
pub type Keep {
  Keep
  Drop
}

/// Like `list.filter` but uses a `filter` that returns `Keep` instead
/// of a `Bool` value.
///
pub fn keep(from list: List(a), with filter: fn(a) -> Keep) {
  list
  |> list.filter(fn(a) { filter(a) == Keep })
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
