import gleam/int
import glacier/should
import glicine/types.{Drop, Keep}
import glicine/utils

pub fn is_markdown_test() {
  "test.md"
  |> utils.is_markdown
  |> should.equal(True)

  "test.md.not_md"
  |> utils.is_markdown
  |> should.equal(False)

  "test.not_md"
  |> utils.is_markdown
  |> should.equal(False)

  "not_md"
  |> utils.is_markdown
  |> should.equal(False)
}

pub fn all_errors_test() {
  []
  |> utils.result_partition
  |> should.be_ok
  |> should.equal([])

  [Ok(1), Ok(2), Ok(3)]
  |> utils.result_partition
  |> should.be_ok
  |> should.equal([1, 2, 3])

  [Error("a"), Error("b"), Error("c")]
  |> utils.result_partition
  |> should.be_error
  |> should.equal(["a", "b", "c"])

  [Error("a"), Ok(1), Ok(2)]
  |> utils.result_partition
  |> should.be_error
  |> should.equal(["a"])

  [Ok(1), Ok(2), Error("a")]
  |> utils.result_partition
  |> should.be_error
  |> should.equal(["a"])

  [Ok(1), Error("a"), Ok(2), Error("b"), Error("c")]
  |> utils.result_partition
  |> should.be_error
  |> should.equal(["a", "b", "c"])
}

pub fn list_keep_test() {
  [1, 2, 3, 4]
  |> utils.list_keep(fn(_) { Drop })
  |> should.equal([])

  [1, 2, 3, 4]
  |> utils.list_keep(fn(_) { Keep })
  |> should.equal([1, 2, 3, 4])

  [1, 2, 3, 4]
  |> utils.list_keep(fn(n) {
    case int.is_even(n) {
      True -> Drop
      False -> Keep
    }
  })
  |> should.equal([1, 3])
}

pub fn duplicates_test() {
  []
  |> utils.duplicates
  |> should.equal([])

  [1, 2, 3, 4]
  |> utils.duplicates
  |> should.equal([])

  [1, 2, 3, 2, 4]
  |> utils.duplicates
  |> should.equal([2])

  [1, 1, 2, 1, 3, 4]
  |> utils.duplicates
  |> should.equal([1])
}
