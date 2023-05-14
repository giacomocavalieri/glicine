import gleam/int
import glicine/filter.{Drop, Keep}
import glacier/should

pub fn keep_test() {
  []
  |> filter.keep(fn(_) { Drop })
  |> should.equal([])

  []
  |> filter.keep(fn(_) { Keep })
  |> should.equal([])

  [1, 2, 3, 4]
  |> filter.keep(fn(_) { Keep })
  |> should.equal([1, 2, 3, 4])

  [1, 2, 3, 4]
  |> filter.keep(fn(_) { Drop })
  |> should.equal([])

  [1, 2, 3, 4]
  |> filter.keep(fn(n) {
    case int.is_odd(n) {
      True -> Keep
      False -> Drop
    }
  })
  |> should.equal([1, 3])
}
