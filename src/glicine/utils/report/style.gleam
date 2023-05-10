import gleam_community/ansi

pub fn title(string: String) -> String {
  string
  |> ansi.magenta
  |> ansi.bold
  |> ansi.italic
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
}

pub fn name(string: String) -> String {
  "\"" <> string <> "\""
  |> ansi.bold
}

pub fn warning(string: String) -> String {
  string
  |> ansi.yellow
}

pub fn error(string: String) -> String {
  string
  |> ansi.red
}
