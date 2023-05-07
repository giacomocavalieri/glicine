//// This module exposes all the main types used by other glicine modules.
////

import gleam/map.{Map}
import gleam/erlang/file

/// It indicates wether an element should be kept or dropped from a list.
///
pub type Keep {
  Keep
  Drop
}

/// TODO: use an external HTML library
///
pub type Html {
  HtmlPlaceholder
}

/// A blog post: it has a `name` (tipically it is the name of the file
/// from which the post's body was read), an Html `body` and additional
/// metadata in the form of a map of strings.
///
pub type Post {
  Post(name: String, metadata: Map(String, String), body: Html)
}

/// A blog page: it has an html `body` and a `name` that indicates
/// the path -- inside the generated site directory -- where the page
/// will be saved.
///
pub type Page {
  Page(name: String, body: Html)
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

/// The reason why one of the blog generation steps may fail.
///
pub type Reason {
  /// Occurs when the posts directory's content cannot be listed.
  ///
  CannotListDirectory(directory: String, reason: file.Reason)

  /// Used to accumulate `FileToPostError` that may
  /// occur in the step that converts files to posts.
  ///
  InvalidPosts(reasons: List(FileToPostError))

  /// Used to accumulate `PageGenerationError` that
  /// may occur in the step that converts posts to pages.
  ///
  PageGenerationStepFailed(reasons: List(PageGenerationError))

  /// Occurs when, after the page generation step, there are two
  /// or more pages with exactly the same name.
  ///
  ClashingPagesName(name: String)
}

/// An error that may occur while trying to read a file and convert
/// it to a post.
///
pub type FileToPostError {
  /// Occurs when a file's content cannot be read.
  ///
  CannotReadFile(file: String, reason: file.Reason)

  /// Occurs if the file's frontmatter doesn't contain valid YAML.
  /// TODO: depending on the library used, it should wrap the decoding error.
  ///
  InvalidMetadata

  /// Occurs if the file's content is not valid Markdown.
  /// TODO: depending on the library used, it should wrap the decoding error.
  ///
  InvalidMarkdown
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
  WrongMetadataFormat(generator: String, post: Post)

  /// A generic error that may occur while trying to convert a post to a page.
  ///
  GenericError(generator: String, posts: List(Post), reason: String)
}
