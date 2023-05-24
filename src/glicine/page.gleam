//// TODO: WIP
////

import gleam/erlang/file
import gleam/list
import gleam/result
import gleam/string_builder.{StringBuilder} as sb
import glicine/extra/directory
import glicine/extra/path
import glicine/extra/result as result_extra
import glicine/extra/string as string_extra
import glicine/extra/style
import glicine/post.{Post}
import glicine/report
import nakai
import nakai/html

/// A blog page: it has an html `body`, a `path` -- relative to the
/// output directory -- where it will be saved, and a `name`.
///
pub type Page {
  Page(path: String, name: String, body: html.Node(Nil))
}

/// A step of the page generation pipeline. It has a `name` used to
/// describe its purpose and report better error messages; it also has
/// a `generator` function that, given all the blog posts,
/// can generate one or more pages (or fail with a
/// `PageGenerationError`).
///
/// For some examples of how to define custom `PageGenerator` you can
/// read [TODO](TODO).
///
pub type PageGenerator {
  PageGenerator(
    name: String,
    generator: fn(List(Post)) -> Result(List(Page), PageGenerationError),
  )
}

/// An error that may occur while trying to convert a post to a page.
///
pub type PageGenerationError {
  /// Occurs if the page generation cannot proceed since one of the posts
  /// is missing a required metadata key.
  ///
  MissingMetadata(generator: String, post: Post, expected: String)

  /// Occurs if the page generation cannot proceed since one of the posts
  /// defines a metadata key with an unexpected value that cannot be handled.
  /// TODO: maybe the value of metadata should be a dynamic and this error
  ///       could contain the dynamic decoding error.
  ///
  WrongMetadataFormat(generator: String, post: Post, key: String)

  /// A generic error that may occur while trying to convert a post to a page.
  ///
  GenericError(generator: String, posts: List(Post), reason: String)

  /// An error that occurs if a generated page can not be saved in the
  /// site directory.
  ///
  CannotSavePage(page: Page, reason: file.Reason)

  /// An error that occurs if the directory where a page should be saved
  /// cannot be created.
  ///
  CannotCreatePageDirectory(page: Page, reason: file.Reason)
}

/// TODO: add doc
///
pub fn from_posts(
  posts: List(Post),
  with generators: List(PageGenerator),
) -> Result(List(Page), List(PageGenerationError)) {
  generators
  |> list.map(fn(generator) { generator.generator(posts) })
  |> result.partition
  |> result_extra.from_partition
  |> result.map(list.flatten)
}

/// TODO: add doc
///
pub fn write_all(
  pages: List(Page),
  to output_directory: String,
) -> Result(Nil, List(PageGenerationError)) {
  list.map(pages, write_page(_, to: output_directory))
  |> result.partition
  |> result_extra.from_partition
  |> result.replace(Nil)
}

fn write_page(
  page: Page,
  to output_directory: String,
) -> Result(Nil, PageGenerationError) {
  let full_path =
    output_directory
    |> path.concat(page.path)

  let page_file =
    full_path
    |> path.concat(page.name)
    |> path.add_extension("html")

  use _ <- result_extra.try(
    directory.make(full_path),
    map_error: CannotCreatePageDirectory(page, _),
  )

  file.write(to: page_file, contents: nakai.to_string(page.body))
  |> result.map_error(CannotSavePage(page, _))
}

/// TODO
///
pub fn error_to_string_builder(error: PageGenerationError) -> StringBuilder {
  case error {
    MissingMetadata(generator, post, expected) ->
      sb.new()
      |> sb.append("the ")
      |> sb.append(style.name(post.name))
      |> sb.append(" post doesn't define the ")
      |> sb.append(style.code(expected))
      |> sb.append(" metadata key needed by the ")
      |> sb.append(style.name(generator))
      |> sb.append(" generator")

    WrongMetadataFormat(generator, post, key) ->
      sb.new()
      |> sb.append("the ")
      |> sb.append(style.name(generator))
      |> sb.append(" generator couldn't parse the metadata")
      |> sb.append(" associated with the key ")
      |> sb.append(style.code(key))
      |> sb.append(" of the ")
      |> sb.append(style.name(post.name))
      |> sb.append(" post")

    GenericError(generator, posts, reason) -> {
      case list.length(posts) {
        0 ->
          sb.new()
          |> sb.append("the ")
          |> sb.append(style.name(generator))
          |> sb.append(" generator failed with the following reason: ")
          |> sb.append(reason)

        n -> {
          let posts_builder =
            posts
            |> list.map(fn(post) { post.name })
            |> list.map(style.name)
            |> list.map(sb.from_string)
            |> sb.join(", ")

          sb.new()
          |> sb.append("the ")
          |> sb.append(style.name(generator))
          |> sb.append(" generator had a problem with the ")
          |> sb.append_builder(posts_builder)
          |> sb.append(" ")
          |> sb.append(string_extra.pick_form(n, "post", "posts"))
          |> sb.append(": ")
          |> sb.append(reason)
        }
      }
    }

    CannotSavePage(page, reason) ->
      sb.new()
      |> sb.append("I cannot write the page ")
      |> sb.append(style.name(page.name))
      |> sb.append(" to ")
      |> sb.append(style.path(page.path))
      |> sb.append(" ")
      |> sb.append_builder(report.default_file_reason(reason))

    CannotCreatePageDirectory(page, reason) ->
      sb.new()
      |> sb.append("I cannot create the ")
      |> sb.append(style.path(page.path))
      |> sb.append(" directory needed by one of the pages ")
      |> sb.append(case reason {
        file.Eacces -> "because I don't have the needed permission"
        file.Enoent -> "because it has an invalid name"
        _ -> sb.to_string(report.default_file_reason(reason))
      })
  }
}
