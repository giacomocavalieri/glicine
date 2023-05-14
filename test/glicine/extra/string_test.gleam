import glacier/should
import glicine/extra/string

pub fn pick_form_test() {
  string.pick_form(0, "singular", "plural")
  |> should.equal("plural")

  string.pick_form(1, "singular", "plural")
  |> should.equal("singular")

  string.pick_form(2, "singular", "plural")
  |> should.equal("plural")

  string.pick_form(200, "singular", "plural")
  |> should.equal("plural")
}
