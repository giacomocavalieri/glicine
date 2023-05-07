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
  // Empty list
  []
  |> utils.result_partition
  |> should.be_ok
  |> should.equal([])

  // All Ok
  [Ok(1), Ok(2), Ok(3)]
  |> utils.result_partition
  |> should.be_ok
  |> should.equal([1, 2, 3])

  // All Error
  [Error("a"), Error("b"), Error("c")]
  |> utils.result_partition
  |> should.be_error
  |> should.equal(["a", "b", "c"])

  // First is Error
  [Error("a"), Ok(1), Ok(2)]
  |> utils.result_partition
  |> should.be_error
  |> should.equal(["a"])

  // Last is Error
  [Ok(1), Ok(2), Error("a")]
  |> utils.result_partition
  |> should.be_error
  |> should.equal(["a"])

  // Mixed Oks and Errors
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
