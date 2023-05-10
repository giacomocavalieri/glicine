//// This module exposes a series of functions to turn different failure
//// reasons into error strings.
////

import gleam/list
import gleam/string_builder.{StringBuilder} as sb
import gleam/erlang/file
import glicine/types.{
  CannotCreateDirectory, CannotListDirectory, CannotReadFile, CannotWritePage,
  DuplicateNamesError, FileToPostError, GenericError, InvalidMarkdown,
  InvalidMetadata, InvalidPosts, MissingMetadata, Page, PageGenerationError,
  PageGenerationStepFailed, Post, Reason, WrongMetadataFormat,
}
import glicine/utils
import glicine/utils/report/style
import gleam/string

pub fn to_string(reason: Reason) -> String {
  case reason {
    CannotListDirectory(directory, reason) ->
      cannot_list_directory(directory, reason)
    CannotCreateDirectory(directory, reason) ->
      cannot_create_directory(directory, reason)
    CannotWritePage(page, reason) -> cannot_write_page(page, reason)
    InvalidPosts(reasons) -> invalid_posts(reasons)
    PageGenerationStepFailed(reasons) -> page_generation_step_failed(reasons)
  }
  |> sb.to_string
}

fn cannot_list_directory(
  directory: String,
  reason: file.Reason,
) -> StringBuilder {
  sb.new()
  |> sb.append("I cannot read the posts in ")
  |> sb.append(style.path(directory))
  |> sb.append(" ")
  |> sb.append(case reason {
    file.Enoent -> "because it doesn't exists"
    file.Eacces -> "because I don't have the needed permission"
    file.Enotdir -> "because it is not a directory"
    _ -> default_file_reason(reason)
  })
}

fn cannot_create_directory(
  directory: String,
  reason: file.Reason,
) -> StringBuilder {
  sb.new()
  |> sb.append("I cannot create the ")
  |> sb.append(style.path(directory))
  |> sb.append(" directory needed by one of the pages ")
  |> sb.append(case reason {
    file.Eacces -> "because I don't have the needed permission"
    file.Enoent -> "because it has an invalid name"
    _ -> default_file_reason(reason)
  })
}

fn cannot_write_page(page: Page, reason: file.Reason) -> StringBuilder {
  sb.new()
  |> sb.append("I cannot write the page ")
  |> sb.append(style.name(page.name))
  |> sb.append(" to ")
  |> sb.append(style.path(page.path))
  |> sb.append(" ")
  |> sb.append(default_file_reason(reason))
}

fn invalid_posts(reasons: List(FileToPostError)) -> StringBuilder {
  sb.new()
  |> sb.append("I had a problem with ")
  |> sb.append(utils.pick_form(list.length(reasons), "a file", "multiple files"))
  |> sb.append(":\n")
  |> sb.append_builder(error_list(reasons, file_post_error))
}

fn error_list(
  from list: List(a),
  with fun: fn(a) -> StringBuilder,
) -> StringBuilder {
  list
  |> list.map(fun)
  |> list.map(sb.prepend(_, "✗ "))
  |> sb.join(with: "\n")
}

fn file_post_error(error: FileToPostError) -> StringBuilder {
  case error {
    CannotReadFile(file, reason) -> cannot_read_file(file, reason)
    InvalidMetadata(_file) -> todo("invalid metadata")
    InvalidMarkdown(_file) -> todo("invalid markdown")
  }
}

fn cannot_read_file(file: String, reason: file.Reason) -> StringBuilder {
  sb.new()
  |> sb.append("I cannot read the file ")
  |> sb.append(style.path(file))
  |> sb.append(" ")
  |> sb.append(case reason {
    file.Enoent -> "because it doesn't exists"
    file.Eacces -> "because I don't have the needed permission"
    _ -> default_file_reason(reason)
  })
}

fn page_generation_step_failed(
  reasons: List(PageGenerationError),
) -> StringBuilder {
  sb.new()
  |> sb.append("I had ")
  |> sb.append(utils.pick_form(
    list.length(reasons),
    "a problem",
    "some problems",
  ))
  |> sb.append(" while generating the blog pages:\n")
  |> sb.append_builder(error_list(reasons, page_generation_error))
}

fn page_generation_error(error: PageGenerationError) -> StringBuilder {
  case error {
    MissingMetadata(generator, post, expected) ->
      missing_metadata(generator, post, expected)
    WrongMetadataFormat(generator, post, key) ->
      wrong_metadata_format(generator, post, key)
    GenericError(generator, posts, reason) ->
      generic_error(generator, posts, reason)
    DuplicateNamesError(names) -> duplicate_names_error(names)
  }
}

fn missing_metadata(
  generator: String,
  post: Post,
  expected: String,
) -> StringBuilder {
  sb.new()
  |> sb.append("the ")
  |> sb.append(style.name(post.name))
  |> sb.append(" post doesn't define the ")
  |> sb.append(style.code(expected))
  |> sb.append(" metadata key needed by the ")
  |> sb.append(style.name(generator))
  |> sb.append(" generator")
}

fn wrong_metadata_format(generator: String, post: Post, key: String) {
  sb.new()
  |> sb.append("the ")
  |> sb.append(style.name(generator))
  |> sb.append(" generator couldn't parse the metadata")
  |> sb.append(" associated with the key ")
  |> sb.append(style.code(key))
  |> sb.append(" of the ")
  |> sb.append(style.name(post.name))
  |> sb.append(" post")
}

fn generic_error(generator: String, posts: List(Post), reason: String) {
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
  |> sb.append(utils.pick_form(list.length(posts), "post", "posts"))
  |> sb.append(": ")
  |> sb.append(reason)
}

fn duplicate_names_error(names: List(String)) -> StringBuilder {
  let names_builder =
    names
    |> list.map(style.name)
    |> list.map(sb.from_string)
    |> sb.join(", ")

  sb.new()
  |> sb.append(utils.pick_form(
    list.length(names),
    "two or more pages share the same name",
    "there are duplicate names between the pages",
  ))
  |> sb.append(": ")
  |> sb.append_builder(names_builder)
  |> sb.append("; this means that one would overwrite the other! ")
  |> sb.append("Make sure that all generated pages have unique names")
}

fn default_file_reason(reason: file.Reason) -> String {
  sb.new()
  |> sb.append("because of an unexpected error (")
  |> sb.append(string.inspect(reason))
  |> sb.append(")")
  |> sb.to_string
}
