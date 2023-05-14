import glacier
import glacier/should
import gleam/erlang/file
import gleam/result
import glicine.{PostsGenerationStepFailed}
import glicine/extra/directory
import glicine/filter.{Keep}
import glicine/page.{Page, PageGenerator}
import glicine/post.{CannotListPostsDirectory}
import nakai/html

pub fn main() {
  glacier.main()
}

// TODO: these tests are a bit messym I should find a better way to 
// perform setup and cleanup of system directories

fn singleton_generator(page_name: String) {
  PageGenerator(
    name: "const",
    generator: fn(_) {
      Ok([Page(name: page_name, path: ".", body: html.Nothing)])
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
  use _ <- result.try(directory.make(posts_dir))
  use _ <- result.try(directory.make(site_dir))
  let assertion = do(posts_dir, site_dir)
  use _ <- result.try(file.recursive_delete(posts_dir))
  use _ <- result.map(file.recursive_delete(site_dir))
  assertion()
}

pub fn invalid_post_directory_test() {
  glicine.make_site(from: "", to: "", filtering: keep_all, with: [])
  |> should.be_error
  |> should.equal(PostsGenerationStepFailed([
    CannotListPostsDirectory("", file.Enoent),
  ]))

  glicine.make_site(from: "nodir", to: "", filtering: keep_all, with: [])
  |> should.be_error
  |> should.equal(PostsGenerationStepFailed([
    CannotListPostsDirectory("nodir", file.Enoent),
  ]))
}

pub fn invalid_site_directory_test() {
  glicine.make_site(
    from: ".",
    to: "",
    filtering: keep_all,
    with: [singleton_generator("page")],
  )
  // TODO: site directory generation should be 
  //       in a separate step
  //|> should.be_error
  //|> should.equal(PageGenerationStepFailed([
  //  CannotCreateSiteDirectory("", file.Enoent),
  //]))
}

pub fn one_page_test() {
  use posts_dir, site_dir <- with_temp_directories
  glicine.make_site(
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
  glicine.make_site(
    from: posts_dir,
    to: site_dir,
    filtering: keep_all,
    with: [],
  )
  |> should.be_ok

  let files = file.list_directory(site_dir)

  fn() {
    files
    |> should.be_ok
    |> should.equal([])
  }
}
