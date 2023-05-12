//// TODO
////

import gleam/erlang/file
import gleam/string
import gleam/string_builder.{StringBuilder} as sb

/// TODO
///
pub fn default_file_reason(reason: file.Reason) -> StringBuilder {
  sb.new()
  |> sb.append("because of an unexpected error (")
  |> sb.append(string.inspect(reason))
  |> sb.append(")")
}
