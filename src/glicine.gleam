import glicine/pages
import glicine/posts
import glicine/types.{Keep, PageGenerator, Post, Reason}
import glicine/utils
import gleam/result

pub fn main(
  posts_directory: String,
  output_directory: String,
  filter: fn(Post) -> Keep,
  generators: List(PageGenerator),
) -> Result(Nil, Reason) {
  posts.read(posts_directory)
  |> result.map(utils.list_keep(_, with: filter))
  |> result.then(pages.from_posts(_, with: generators))
  |> result.then(pages.write(_, to: output_directory))
  // |> report the success of the generation or any error that
  //    may have taken place
  // |> in case an error occurs delete the output directory
}
