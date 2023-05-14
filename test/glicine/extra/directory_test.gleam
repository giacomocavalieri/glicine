import gleam/erlang/file
import gleam/result
import glacier/should
import glicine/extra/directory

pub fn make_creates_all_subdirectories_test() {
  let directory = "foo_test/bar_test/baz_test"
  use _ <- result.try(directory.make(directory))
  let is_directory = file.is_directory(directory)
  use _ <- result.try(file.recursive_delete("foo_test"))
  is_directory
  |> should.equal(True)
  Ok(Nil)
}
