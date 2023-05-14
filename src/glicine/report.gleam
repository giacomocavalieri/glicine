//// This module exposes some common functions used by the steps of the site generation
//// pipeline to turn errors into error messages.
////

import gleam/erlang/file
import gleam/string
import gleam/string_builder.{StringBuilder} as sb

/// Turns a `file.Reason` into a `StringBuilder` with a default message
/// that displays the failure reason.
///
pub fn default_file_reason(reason: file.Reason) -> StringBuilder {
  sb.new()
  |> sb.append("because of an unexpected error (")
  |> sb.append(string.inspect(reason))
  |> sb.append(")")
}
