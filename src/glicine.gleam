import glicine/pages
import glicine/posts
import glicine/types.{Keep, PageGenerator, Post, Reason}
import glicine/utils
import glicine/utils/report
import gleam/result

pub fn generate(
  posts_directory: String,
  output_directory: String,
  filter: fn(Post) -> Keep,
  generators: List(PageGenerator),
) -> Result(Nil, Reason) {
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
  // |> report the success of the generation or any error that
  //    may have taken place
  // |> in case an error occurs delete the output directory
}

pub fn main() {
  let filter = fn(_) { Keep }
  let generators = []

  //PageGenerator("Empty1", fn(_) { Ok([]) }),
  //PageGenerator("Empty2", fn(_) { Ok([]) }),
  generate(
    "/Users/giacomocavalieri/Desktop/posts_prova",
    "site",
    filter,
    generators,
  )
}
