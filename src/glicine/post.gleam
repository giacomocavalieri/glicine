//// This module exposes the [`read`](#read) function. It is used to
//// read markdown files as blog posts to be used for the static
//// website generation.
////
//// To get a better insight of how the blog generation pipeline
//// works you can find a more detailed explanation in the [README](TODO).
////

import gleam/erlang/file
import gleam/list
import gleam/map.{Map}
import gleam/result
import gleam/string
import gleam/string_builder.{StringBuilder} as sb
import glicine/extra/path
import glicine/extra/result as result_extra
import glicine/extra/style
import glicine/html.{Html, HtmlPlaceholder}
import glicine/report

/// A blog post: it has a `name` (tipically it is the name of the file
/// from which the post's body was read), an Html `body` and additional
/// metadata in the form of a map of strings.
///
pub type Post {
  Post(name: String, metadata: Map(String, String), body: Html)
}

/// An error that may occur while trying to read a file and convert
/// it to a post.
///
pub type PostGenerationError {
  /// Occurs when the directory containing all the post files cannot
  /// be listed.
  ///
  CannotListPostsDirectory(directory: String, reason: file.Reason)

  /// Occurs when a file's content cannot be read.
  ///
  CannotReadFile(file: String, reason: file.Reason)

  /// Occurs if the file's frontmatter doesn't contain valid YAML.
  /// TODO: depending on the library used, it should wrap the decoding error.
  ///
  InvalidMetadata(file: String)

  /// Occurs if the file's content is not valid Markdown.
  /// TODO: depending on the library used, it should wrap the decoding error.
  ///
  InvalidMarkdown(file: String)
}

/// TODO
///
pub fn error_to_string_builder(error: PostGenerationError) -> StringBuilder {
  case error {
    CannotListPostsDirectory(directory, reason) ->
      sb.new()
      |> sb.append("I cannot read the posts in ")
      |> sb.append(style.path(directory))
      |> sb.append(" ")
      |> sb.append(case reason {
        file.Enoent -> "because it doesn't exists"
        file.Eacces -> "because I don't have the needed permission"
        file.Enotdir -> "because it is not a directory"
        _ -> sb.to_string(report.default_file_reason(reason))
      })

    CannotReadFile(file, reason) ->
      sb.new()
      |> sb.append("I cannot read the file ")
      |> sb.append(style.path(file))
      |> sb.append(" ")
      |> sb.append(case reason {
        file.Enoent -> "because it doesn't exists"
        file.Eacces -> "because I don't have the needed permission"
        _ -> sb.to_string(report.default_file_reason(reason))
      })

    InvalidMetadata(_file) -> todo("Invalid metadata")
    InvalidMarkdown(_file) -> todo("Invalid markdown")
  }
}

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
pub fn read_all(
  in directory: String,
) -> Result(List(Post), List(PostGenerationError)) {
  directory
  |> file.list_directory
  |> result.map_error(fn(reason) {
    [CannotListPostsDirectory(directory, reason)]
  })
  |> result.map(list.filter(_, path.has_extension(_, ".md")))
  |> result.try(files_to_posts)
}

fn files_to_posts(
  files: List(String),
) -> Result(List(Post), List(PostGenerationError)) {
  files
  |> list.map(file_to_post)
  |> result_extra.partition
}

fn file_to_post(file: String) -> Result(Post, PostGenerationError) {
  let name = string.drop_right(from: file, up_to: 3)
  // TODO:
  // Read file content   (cannot open file)
  // Extract metadata    (invalid metadata)
  // markdown -> HTML    (invalid markdown)
  Post(name: name, metadata: map.new(), body: HtmlPlaceholder)
  |> Ok
}
