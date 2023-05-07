//// This module exposes the [`read`](#read) function. It is used to
//// read markdown files as blog posts to be used for the static
//// website generation.
////
//// To get a better insight of how the blog generation pipeline
//// works you can find a more detailed explanation in the [README](TODO).
////

import gleam/list
import gleam/map
import gleam/result
import gleam/string
import gleam/erlang/file
import glicine/types.{
  CannotListDirectory, FileToPostError, InvalidPosts, Post, Reason,
}
import glicine/utils

/// Reads the content of all `.md` files in the given directory (the 
/// directory is not descended recursively) and converts each one
/// into a post.
///
/// The post name is the same of the file, while the body is obtained
/// by converting the markdown content of the file to HTML.
/// To specify further metadata the markdown file may include a YAML
/// frontmatter; for example:
///
/// ```
/// ---
/// title: "My first blog post"
/// draft: True
/// ---
/// ```
///
pub fn read(in directory: String) -> Result(List(Post), Reason) {
  directory
  |> file.list_directory
  |> result.map_error(CannotListDirectory(directory, _))
  |> result.map(list.filter(_, utils.is_markdown))
  |> result.then(files_to_posts)
}

fn files_to_posts(files: List(String)) -> Result(List(Post), Reason) {
  files
  |> list.map(file_to_post)
  |> utils.result_partition
  |> result.map_error(InvalidPosts)
}

fn file_to_post(file: String) -> Result(Post, FileToPostError) {
  let name = string.drop_right(from: file, up_to: 3)
  // Read file content   (cannot open file)
  // Extract metadata    (invalid metadata)
  // markdown -> HTML    (invalid markdown)
  Post(name: name, metadata: map.new(), body: types.HtmlPlaceholder)
  |> Ok
}
