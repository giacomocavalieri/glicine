//// TODO: WIP
////

import glicine/types.{Page, PageGenerator, Post, Reason}

/// TODO: WIP
/// It calls each generator with the provided list of posts and
/// accumulates all the generated pages in a single list.
///
pub fn from_posts(
  posts: List(Post),
  with generators: List(PageGenerator),
) -> Result(List(Page), Reason) {
  todo
  // TODO check for name clashes!
}
