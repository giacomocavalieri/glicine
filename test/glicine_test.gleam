import glacier
import glacier/should
import glicine
import glicine/types.{
  CannotCreateDirectory, CannotListDirectory, HtmlPlaceholder, Keep, Page,
  PageGenerator,
}
import gleam/erlang/file
import gleam/result
import glicine/utils

pub fn main() {
  glacier.main()
}

fn singleton_generator(page_name: String) {
  PageGenerator(
    name: "const",
    generator: fn(_) {
      Ok([Page(name: page_name, path: ".", body: HtmlPlaceholder)])
    },
  )
}

fn keep_all(_: a) -> Keep {
  Keep
}

fn with_temp_directories(
  do: fn(String, String) -> fn() -> Nil,
) -> Result(Nil, file.Reason) {
  let site_dir = "site_temp"
  let posts_dir = "posts_temp"
  use _ <- result.then(utils.make_directory(posts_dir))
  use _ <- result.then(utils.make_directory(site_dir))
  let assertion = do(posts_dir, site_dir)
  use _ <- result.then(file.recursive_delete(posts_dir))
  use _ <- result.map(file.recursive_delete(site_dir))
  assertion()
}

pub fn invalid_post_directory_test() {
  glicine.generate(from: "", to: "", filtering: keep_all, with: [])
  |> should.be_error
  |> should.equal(CannotListDirectory("", file.Enoent))

  glicine.generate(from: "nodir", to: "", filtering: keep_all, with: [])
  |> should.be_error
  |> should.equal(CannotListDirectory("nodir", file.Enoent))
}

pub fn invalid_site_directory_test() {
  glicine.generate(
    from: ".",
    to: "",
    filtering: keep_all,
    with: [singleton_generator("page")],
  )
  |> should.be_error
  |> should.equal(CannotCreateDirectory("", file.Enoent))
}

pub fn one_page_test() {
  use posts_dir, site_dir <- with_temp_directories
  glicine.generate(
    from: posts_dir,
    to: site_dir,
    filtering: keep_all,
    with: [singleton_generator("page")],
  )
  |> should.be_ok

  let files = file.list_directory(site_dir)

  fn() {
    files
    |> should.be_ok
    |> should.equal(["page.html"])
  }
}

pub fn zero_pages_test() {
  use posts_dir, site_dir <- with_temp_directories
  glicine.generate(from: posts_dir, to: site_dir, filtering: keep_all, with: [])
  |> should.be_ok

  let files = file.list_directory(site_dir)

  fn() {
    files
    |> should.be_ok
    |> should.equal([])
  }
}
