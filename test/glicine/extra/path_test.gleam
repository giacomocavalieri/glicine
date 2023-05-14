import glacier/should
import glicine/extra/path

pub fn concat_test() {
  "."
  |> path.concat("path")
  |> path.concat("to")
  |> path.concat("file.txt")
  |> should.equal("./path/to/file.txt")

  "."
  |> path.concat("")
  |> path.concat("   \n\t")
  |> should.equal(".")

  ""
  |> path.concat("")
  |> path.concat("\n  \t")
  |> should.equal("")

  "."
  |> path.concat(".")
  |> path.concat(".")
  |> should.equal(".")

  ""
  |> path.concat("path")
  |> path.concat("    ")
  |> path.concat("to")
  |> path.concat("file.txt")
  |> should.equal("path/to/file.txt")
}

pub fn add_extension_test() {
  "file"
  |> path.add_extension(".html")
  |> should.equal("file.html")

  "file.html"
  |> path.add_extension(".html")
  |> should.equal("file.html")

  "file.foo"
  |> path.add_extension(".html")
  |> should.equal("file.foo.html")

  "file"
  |> path.add_extension("html")
  |> should.equal("file.html")

  "file"
  |> path.add_extension("  \t html ")
  |> should.equal("file.html")

  "file"
  |> path.add_extension("  \t\n \n ")
  |> should.equal("file")
}
