
![Glicine](https://raw.githubusercontent.com/giacomocavalieri/glicine/main/glicine_logo.svg "Glicine")

[![Package Version](https://img.shields.io/hexpm/v/glicine)](https://hex.pm/packages/glicine)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/glicine/)

_A static site generator made with Gleam ✨_

> ❗️ This package relies on Gleam's Erlang FFI so it won't work if you're targeting JavaScript

## Installation

To add this package to your Gleam project:

```sh
gleam add glicine
```

## Another static site generator? Why?

I mainly made Glicine on a whim as a fun project to learn Gleam and I tailor made it based on what I'd like to see in a simple site generator. I'm not a big fan of zero code tools and I _love_ to write code so the choice was pretty obvious: make a customizable site generation pipeline where I can plug my own generators written in Gleam!

If you need a static site generator and are not afraid of writing Gleam code, give it a try, maybe you'll like it (and if you don't and have ideas on how to improve it, please open an issue that's really appreciated!)

## How does it work

Glicine site generation pipeline is based on 4 main steps. Here's an overview of the process:

1. First it reads all markdown files from a given directory and turns them into posts (more on posts [here](#user-content-posts))
2. Then one can specify a custom criteria to filter out posts from the site generation pipeline (more on posts filtering [here](#user-content-filtering))
3. The leftover posts are turned into site pages using custom generators. This is the core of the whole site generation process, there can be as many generators as needed each taking care of a specific aspect of the final site (more on how to use and define custom page generators [here](#user-content-generators))
4. All the generated pages are then saved in a given output directory

If you, like me, love unecessary ascii art graphs, here's the Glicine site generation pipeline:

```
posts directory
  │
  │ 1) read all markdown files
  │    in the posts directory
╭─▽─────╮         
│ posts │         
╰─┬─────╯         
  │ 2) filter out posts based on a
  │    custom criteria
╭─▽──────────────╮
│ leftover posts │
╰─┬──────────────╯
  │ 3) apply a series of generators
  │    to turn each post into a site
  │    page
╭─▽─────╮
│ pages │         
╰─┬─────╯   
  │ 4) save the pages in the
  │    output directory      
  ▽
output directory 
```

The whole process is carried out by the `glicine.make_site` function. So to build your own site import `glicine` and call the function; it has a parameter to customize each step of the pipeline: you can specify the criteria used to filter posts, the source and output directories and the generators to be used.

```gleam
import glicine

glicine.make_site(
    from: posts_directory,
    filtering: filter,
    with: generators,
    to: output_directory,
)
```

## More on the pipeline steps

### Posts

A post represents a markdown file thaat is read from the specified input directory. Glicine reads all markdown files it can find and converts them to posts. Each post consists of:

- A `name` which is the name of the file it was read from
- A `metadata` map obtained by parsing a markdown front matter from the post file
- An html `body` obtained by converting the file's markdown to html

- [ ] TODO: add a reference to the post's doc on hex

### Filtering

It can be particularly useful to exclude some posts from the site generation pipeline: for example, draft posts should be dropped from the generation pipeline.

To filter a post one needs to define a function that, after inspecting a post decides wether to `Keep` or `Drop` it:

```gleam
import glicine/filter.{Drop, Keep}
import glicine/post.{Post}

fn drop_all(_post: Post) -> Keep {
  Drop
}
```

A filter that drops all posts is not that interesting though. Let's consider a more interesting filter:

```gleam
import gleam/map

fn drop_draft(post: Post) -> Keep {
  case post.metadata |> map.get("draft") of {
    Ok("true") -> Drop
    _ -> Keep
  }
}
```

This filter checks if the post has a metadata `draft` set to `"true"`, if it does then the post is dropped.

TODO:

- [ ] the `filter` module could expose some filters that could be useful like the drop drafts one

### Generators

TODO:
- [ ] explain how a generator works
- [ ] explain the different possible errors
- [ ] show a couple examples! Once I've written my own generators the examples could be:
  - [ ] A generator that takes a single post and turns it into an html page starting from a `nakai` template
  - [ ] A generator that takes all the posts and builds a tag index for the website
  - [ ] A generator that ignores the posts and builds an about page that is always the same

For now it doesn't really make sense to write the whole tutorial as I still need to figure out what could be improved with the current generators design, sorry for the imcomplete readme!
