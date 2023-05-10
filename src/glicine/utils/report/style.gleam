import gleam_community/ansi

pub fn title(string: String) -> String {
  string
  |> ansi.magenta
  |> ansi.bold
}

pub fn code(string: String) -> String {
  "`" <> string <> "`"
  |> ansi.dim
}

pub fn path(string: String) -> String {
  string
  |> ansi.dim
  |> ansi.underline
}

pub fn success(string: String) -> String {
  "✓ " <> string
  |> ansi.green
}

pub fn step_report(report: String) -> String {
  "\n" <> report
  |> ansi.italic
}

pub fn name(string: String) -> String {
  "\"" <> string <> "\""
  |> ansi.bold
}
