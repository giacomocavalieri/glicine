import gleam/int
import gleam/function
import glacier/should
import glicine/extra/list.{Drop, Keep} as list_extra
import glicine/extra/result as result_extra
import glicine/extra/path

pub fn is_markdown_test() {
  "test.md"
  |> path.has_extension(".md")
  |> should.equal(True)

  "test.md.not_md"
  |> path.has_extension(".md")
  |> should.equal(False)

  "test.not_md"
  |> path.has_extension(".md")
  |> should.equal(False)

  "not_md"
  |> path.has_extension(".md")
  |> should.equal(False)
}

pub fn all_errors_test() {
  []
  |> result_extra.partition
  |> should.be_ok
  |> should.equal([])

  [Ok(1), Ok(2), Ok(3)]
  |> result_extra.partition
  |> should.be_ok
  |> should.equal([1, 2, 3])

  [Error("a"), Error("b"), Error("c")]
  |> result_extra.partition
  |> should.be_error
  |> should.equal(["a", "b", "c"])

  [Error("a"), Ok(1), Ok(2)]
  |> result_extra.partition
  |> should.be_error
  |> should.equal(["a"])

  [Ok(1), Ok(2), Error("a")]
  |> result_extra.partition
  |> should.be_error
  |> should.equal(["a"])

  [Ok(1), Error("a"), Ok(2), Error("b"), Error("c")]
  |> result_extra.partition
  |> should.be_error
  |> should.equal(["a", "b", "c"])
}

pub fn list_keep_test() {
  [1, 2, 3, 4]
  |> list_extra.keep(function.constant(Drop))
  |> should.equal([])

  [1, 2, 3, 4]
  |> list_extra.keep(function.constant(Keep))
  |> should.equal([1, 2, 3, 4])

  [1, 2, 3, 4]
  |> list_extra.keep(fn(n) {
    case int.is_even(n) {
      True -> Drop
      False -> Keep
    }
  })
  |> should.equal([1, 3])
}

pub fn duplicates_test() {
  []
  |> list_extra.duplicates
  |> should.equal([])

  [1, 2, 3, 4]
  |> list_extra.duplicates
  |> should.equal([])

  [1, 2, 3, 2, 4]
  |> list_extra.duplicates
  |> should.equal([2])

  [1, 1, 2, 1, 3, 4]
  |> list_extra.duplicates
  |> should.equal([1])
}
