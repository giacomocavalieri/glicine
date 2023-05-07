import glicine/pages
import glicine/posts
import glicine/types.{Keep, Page, PageGenerator, Post, Reason}
import glicine/utils
import gleam/result

pub fn main(
  posts_directory: String,
  filter: fn(Post) -> Keep,
  generators: List(PageGenerator),
) -> Result(List(Page), Reason) {
  posts.read(posts_directory)
  |> result.map(utils.list_keep(_, with: filter))
  |> result.then(pages.from_posts(_, with: generators))
  // |> actually write all the pages
  // |> report the success of the generation or any error that
  //    may have taken place
}
