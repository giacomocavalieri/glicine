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
  |> utils.if_ok_do(report.read_posts)
  |> result.map(utils.list_keep(_, with: filter))
  |> utils.if_ok_do(report.filtered_posts)
  |> utils.if_ok_do(fn(_) { report.generating_pages(generators) })
  |> result.try(pages.from_posts(_, with: generators))
  |> utils.if_ok_do(report.generated_pages)
  |> utils.if_ok_do(fn(_) { report.writing_pages(output_directory) })
  |> result.try(pages.write(_, to: output_directory))
  |> utils.if_ok_do(fn(_) { report.completion() })
  |> utils.if_error_do(report.error)
}
