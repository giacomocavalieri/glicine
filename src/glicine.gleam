import glicine/pages
import glicine/posts
import glicine/types.{Keep, PageGenerator, Post, Reason}
import glicine/utils
import glicine/utils/report
import gleam/result

pub fn generate(
  from posts_directory: String,
  to output_directory: String,
  filtering filter: fn(Post) -> Keep,
  with generators: List(PageGenerator),
) -> Result(Nil, Reason) {
  report.introduction()
  report.reading_posts(from: posts_directory)
  posts.read(posts_directory)
  |> if_ok_do(report.read_posts)
  |> result.map(utils.list_keep(_, with: filter))
  |> if_ok_do(report.filtered_posts)
  |> if_ok_do(fn(_) { report.generating_pages(generators) })
  |> result.try(pages.from_posts(_, with: generators))
  |> if_ok_do(report.generated_pages)
  |> if_ok_do(fn(_) { report.writing_pages(output_directory) })
  |> result.try(pages.write(_, to: output_directory))
  |> if_ok_do(fn(_) { report.completion() })
  |> if_error_do(report.error)
}

fn if_ok_do(result: Result(a, e), action: fn(a) -> Nil) -> Result(a, e) {
  use a <- result.map(result)
  action(a)
  a
}

fn if_error_do(result: Result(a, e), action: fn(e) -> Nil) -> Result(a, e) {
  use e <- result.map_error(result)
  action(e)
  e
}
