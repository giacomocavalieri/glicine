//// This module exposes additional functions to work with strings.
////

/// Used to select the plural or singular form based on a number.
///
pub fn pick_form(n: Int, singular: String, plural: String) -> String {
  case n {
    1 -> singular
    _ -> plural
  }
}
