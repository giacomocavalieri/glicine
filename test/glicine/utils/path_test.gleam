import glicine/utils/path
import glacier/should

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

  ""
  |> path.concat("path")
  |> path.concat("    ")
  |> path.concat("to")
  |> path.concat("file.txt")
  |> should.equal("path/to/file.txt")
}
