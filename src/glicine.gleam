//// TODO
////

import gleam/int
import gleam/io
import gleam/list
import gleam/string_builder.{StringBuilder} as sb
import glicine/extra/list.{Keep} as list_extra
import glicine/extra/result as result_extra
import glicine/extra/string as string_extra
import glicine/extra/style
import glicine/page.{Page, PageGenerationError, PageGenerator}
import glicine/post.{Post, PostGenerationError}

/// The reason why one of the blog generation steps may fail.
///
pub type GlicinePipelineError {
  /// Used to accumulate `PostGenerationError` that may
  /// occur in the step that converts files to posts.
  ///
  PostsGenerationStepFailed(reasons: List(PostGenerationError))

  /// Used to accumulate `PageGenerationError` that
  /// may occur in the step that converts posts to pages.
  ///
  PagesGenerationStepFailed(reasons: List(PageGenerationError))
}

pub fn generate(
  from posts_directory: String,
  to output_directory: String,
  filtering filter: fn(Post) -> Keep,
  with generators: List(PageGenerator),
) -> Result(Nil, GlicinePipelineError) {
  use <- result_extra.on_error(do: report_error)

  report_introduction()

  report_reading_posts(from: posts_directory)
  use all_posts <- result_extra.try(
    post.read_all(posts_directory),
    map_error: PostsGenerationStepFailed,
  )
  report_read_posts(all_posts)

  let posts = list_extra.keep(all_posts, with: filter)
  report_filtered_posts(posts)

  report_generating_pages(generators)
  use pages <- result_extra.try(
    page.from_posts(posts, with: generators),
    map_error: PagesGenerationStepFailed,
  )
  report_generated_pages(pages)
  // TODO: check for duplicate names

  report_writing_pages(output_directory)
  use _ <- result_extra.try(
    page.write_all(pages, to: output_directory),
    map_error: PagesGenerationStepFailed,
  )

  report_completion()
  Ok(Nil)
}

fn report_introduction() -> Nil {
  "\n✼ ✿ Glicine ✿ ✼"
  |> style.title
  |> io.println
}

fn report_reading_posts(from directory: String) -> Nil {
  "I'm reading markdown posts from the directory " <> style.path(directory)
  |> style.step_report
  |> io.println
}

fn report_read_posts(posts: List(Post)) -> Nil {
  let posts_count =
    posts
    |> list.length

  sb.new()
  |> sb.append(int.to_string(posts_count))
  |> sb.append(" ")
  |> sb.append(string_extra.pick_form(posts_count, "post", "posts"))
  |> sb.append(" found")
  |> sb.to_string
  |> style.success
  |> io.println
}

fn report_filtered_posts(posts: List(Post)) -> Nil {
  let posts_count =
    posts
    |> list.length

  sb.new()
  |> sb.append(int.to_string(posts_count))
  |> sb.append(" leftover ")
  |> sb.append(string_extra.pick_form(posts_count, "post", "posts"))
  |> sb.append(" after filtering")
  |> sb.to_string
  |> style.success
  |> io.println
}

fn report_generating_pages(generators: List(PageGenerator)) -> Nil {
  let generators_count =
    generators
    |> list.length
  let generators_list =
    generators
    |> list.map(fn(generator) { generator.name })
    |> list.map(style.name)
    |> list.map(sb.from_string)
    |> sb.join(", ")

  case generators_count {
    0 ->
      sb.new()
      |> sb.append("\nLooks like there's no generators, ")
      |> sb.append("I won't be able to generate any page!\n")
      |> sb.append("Maybe you forgot to add your generators to ")
      |> sb.append("the ")
      |> sb.append(style.code("`glicine.generate`"))
      |> sb.append(" call?\n")
      |> sb.append("If you feel lost, you can read more ")
      |> sb.append("about defining and using generators\n")
      |> sb.append("at this link: TODO")
      |> sb.to_string
      |> style.warning
    _ ->
      sb.new()
      |> sb.append("Now I'm generating the blog pages using ")
      |> sb.append(string_extra.pick_form(
        generators_count,
        "this generator",
        "these generators",
      ))
      |> sb.append(":\n")
      |> sb.append_builder(generators_list)
      |> sb.to_string
      |> style.step_report
  }
  |> io.println
}

fn report_generated_pages(pages: List(Page)) -> Nil {
  let pages_count =
    pages
    |> list.length

  sb.new()
  |> sb.append(int.to_string(pages_count))
  |> sb.append(" ")
  |> sb.append(string_extra.pick_form(pages_count, "page", "pages"))
  |> sb.append(" generated")
  |> sb.to_string
  |> style.success
  |> io.println
}

fn report_writing_pages(to directory: String) -> Nil {
  sb.new()
  |> sb.append("Now I'm writing the pages in the directory ")
  |> sb.append(style.path(directory))
  |> sb.to_string
  |> style.step_report
  |> io.println
}

fn report_completion() -> Nil {
  "site generation completed\n"
  |> style.success
  |> io.println
}

fn report_error(error: GlicinePipelineError) -> Nil {
  case error {
    PostsGenerationStepFailed(reasons) ->
      sb.new()
      |> sb.append("I had a problem with ")
      |> sb.append(string_extra.pick_form(
        list.length(reasons),
        "a file",
        "multiple files",
      ))
      |> sb.append(":\n")
      |> sb.append_builder(error_list(reasons, post.error_to_string_builder))
      |> sb.to_string
      |> io.println

    PagesGenerationStepFailed(reasons) ->
      sb.new()
      |> sb.append("I had ")
      |> sb.append(string_extra.pick_form(
        list.length(reasons),
        "a problem",
        "some problems",
      ))
      |> sb.append(" while generating the blog pages:\n")
      |> sb.append_builder(error_list(reasons, page.error_to_string_builder))
      |> sb.to_string
      |> io.println
  }
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
