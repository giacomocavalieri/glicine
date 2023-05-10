import glicine/types.{Page, PageGenerator, Post, Reason}
import glicine/utils
import glicine/utils/report/style
import gleam/io
import gleam/list
import gleam/int
import gleam/string_builder.{StringBuilder} as sb
import glicine/utils/report/reason

pub fn introduction() -> Nil {
  "\n✼ ✿ Glicine ✿ ✼"
  |> style.title
  |> io.println
}

pub fn reading_posts(from directory: String) -> Nil {
  "I'm reading markdown posts from the directory " <> style.path(directory)
  |> style.step_report
  |> io.println
}

pub fn read_posts(posts: List(Post)) -> Nil {
  let posts_count =
    posts
    |> list.length

  sb.new()
  |> sb.append(int.to_string(posts_count))
  |> sb.append(" ")
  |> sb.append(utils.pick_form(posts_count, "post", "posts"))
  |> sb.append(" found")
  |> sb.to_string
  |> style.success
  |> io.println
}

pub fn filtered_posts(posts: List(Post)) -> Nil {
  let posts_count =
    posts
    |> list.length

  sb.new()
  |> sb.append(int.to_string(posts_count))
  |> sb.append(" leftover ")
  |> sb.append(utils.pick_form(posts_count, "post", "posts"))
  |> sb.append(" after filtering")
  |> sb.to_string
  |> style.success
  |> io.println
}

pub fn generating_pages(generators: List(PageGenerator)) -> Nil {
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
      zero_generators_warning()
      |> sb.to_string
      |> style.warning
    _ ->
      sb.new()
      |> sb.append("Now I'm generating the blog pages using ")
      |> sb.append(utils.pick_form(
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

fn zero_generators_warning() -> StringBuilder {
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
}

pub fn generated_pages(pages: List(Page)) -> Nil {
  let pages_count =
    pages
    |> list.length

  sb.new()
  |> sb.append(int.to_string(pages_count))
  |> sb.append(" ")
  |> sb.append(utils.pick_form(pages_count, "page", "pages"))
  |> sb.append(" generated")
  |> sb.to_string
  |> style.success
  |> io.println
}

pub fn writing_pages(to directory: String) -> Nil {
  sb.new()
  |> sb.append("Now I'm writing the pages in the directory ")
  |> sb.append(style.path(directory))
  |> sb.to_string
  |> style.step_report
  |> io.println
}

pub fn completion() -> Nil {
  "site generation completed\n"
  |> style.success
  |> io.println
}

pub fn error(reason: Reason) -> Nil {
  reason.to_string(reason)
  |> style.step_report
  |> style.error
  |> io.println
}
