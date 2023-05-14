//// This module exposes additional functions used to work with lists. 
////

import gleam/function
import gleam/list
import gleam/map

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
