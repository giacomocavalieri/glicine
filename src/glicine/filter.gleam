//// This module exposes the `keep` method used to drop elements from a list
//// based on the result of a predicate that returns either `Keep` or `Drop`.
////

import gleam/list

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
