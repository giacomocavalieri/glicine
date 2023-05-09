//// TODO: WIP
////

import glicine/types.{
  CannotCreateDirectory, CannotWritePage, DuplicateNamesError, Page,
  PageGenerationStepFailed, PageGenerator, Post, Reason,
}
import glicine/utils
import glicine/utils/path
import gleam/list
import gleam/result
import gleam/erlang/file

/// TODO: WIP
/// It calls each generator with the provided list of posts and
/// accumulates all the generated pages in a single list.
///
pub fn from_posts(
  posts: List(Post),
  with generators: List(PageGenerator),
) -> Result(List(Page), Reason) {
  generators
  |> list.map(fn(generator) { generator.generator(posts) })
  |> utils.result_partition
  |> result.map(list.flatten)
  |> result.map_error(PageGenerationStepFailed)
  |> result.then(check_duplicate_names)
}

fn check_duplicate_names(pages: List(Page)) -> Result(List(Page), Reason) {
  let duplicated_names =
    pages
    |> list.map(fn(page) { page.name })
    |> utils.duplicates

  case duplicated_names {
    [] -> Ok(pages)
    _ ->
      [DuplicateNamesError(duplicated_names)]
      |> PageGenerationStepFailed
      |> Error
  }
}

/// TODO: WIP
/// Add doc
///
pub fn write(
  pages: List(Page),
  to output_directory: String,
) -> Result(Nil, Reason) {
  list.try_map(pages, write_page(_, to: output_directory))
  |> result.replace(Nil)
}

fn write_page(page: Page, to output_directory: String) -> Result(Nil, Reason) {
  use full_path <- result.then(make_page_directory(page, output_directory))
  let page_file =
    full_path
    |> path.concat(page.name)
    |> path.add_extension("html")

  // TODO: Depending on the HTML library there should be a way to turn it into a string
  file.write(to: page_file, contents: "todo")
  |> result.map_error(CannotWritePage(page, _))
}

fn make_page_directory(
  page: Page,
  output_directory: String,
) -> Result(String, Reason) {
  let full_path =
    output_directory
    |> path.concat(page.path)

  full_path
  |> utils.make_directory
  |> result.map_error(CannotCreateDirectory(full_path, _))
  |> result.replace(full_path)
}
