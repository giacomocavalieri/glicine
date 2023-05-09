import glicine/pages
import glicine/posts
import glicine/types.{HtmlPlaceholder, Keep, Page, PageGenerator, Post}
import glicine/utils
import glicine/utils/report
import gleam/result
import gleam/function

pub fn generate(
  posts_directory: String,
  output_directory: String,
  filter: fn(Post) -> Keep,
  generators: List(PageGenerator),
) -> Nil {
  report.introduction()
  report.reading_posts(from: posts_directory)
  posts.read(posts_directory)
  |> utils.if_ok_do(report.read_posts)
  |> result.map(utils.list_keep(_, with: filter))
  |> utils.if_ok_do(report.filtered_posts)
  |> utils.if_ok_do(fn(_) { report.generating_pages(generators) })
  |> result.then(pages.from_posts(_, with: generators))
  |> utils.if_ok_do(report.generated_pages)
  |> utils.if_ok_do(fn(_) { report.writing_pages(output_directory) })
  |> result.then(pages.write(_, to: output_directory))
  |> utils.if_ok_do(fn(_) { report.completion() })
  |> utils.if_error_do(report.error)
  |> function.constant(Nil)
  // |> in case an error occurs delete the output directory
}

pub fn main() {
  let filter = fn(_) { Keep }
  let generators = [
    PageGenerator(
      "Empty1",
      fn(_) {
        Ok([Page(name: "hello", path: "posts/new", body: HtmlPlaceholder)])
      },
    ),
  ]

  //
  //PageGenerator("Empty2", fn(_) { Ok([]) }),
  generate(
    "/Users/giacomocavalieri/Desktop/posts_provaa",
    "site",
    filter,
    generators,
  )
}
