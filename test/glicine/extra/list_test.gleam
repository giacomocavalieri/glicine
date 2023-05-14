import gleam/set
import glicine/extra/list as extra_list
import glacier/should

pub fn duplicates_test() {
  []
  |> extra_list.duplicates
  |> should.equal([])

  [1, 2, 3]
  |> extra_list.duplicates
  |> should.equal([])

  [1, 2, 1, 3, 2, 4]
  |> extra_list.duplicates
  |> set.from_list
  |> should.equal(set.from_list([1, 2]))

  [[1, 2], [3], [1, 2]]
  |> extra_list.duplicates
  |> should.equal([[1, 2]])
}
