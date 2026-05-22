// IMPORTS ---------------------------------------------------------------------

import argv
import child_process.{Output}
import filepath
import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/json
import gleam/list
import gleam/option
import gleam/package_interface.{
  type Function, type Module, type Type, type TypeConstructor,
  type TypeDefinition, Fn, Named, Tuple, Variable,
}
import gleam/regexp
import gleam/string
import justin
import simplifile

// MAIN ------------------------------------------------------------------------

pub fn main() -> Nil {
  let #(path, modules) = case argv.load().arguments {
    [path] -> #(path, [])
    [path, "--filter", ..modules] -> #(path, modules)
    _ -> panic as "Usage: gleam run -- <path-to-lustre/ui> (--filter ..modules)"
  }

  let assert Ok(cwd) = simplifile.current_directory()
  let outfile = filepath.join(cwd, "package-interface.json")
  let assert Ok(Output(status_code: 0, ..)) =
    child_process.exec(
      "gleam",
      ["export", "package-interface", "--out", outfile],
      path,
    )

  let assert Ok(json) = simplifile.read(outfile)
  let assert Ok(interface) = json.parse(json, package_interface.decoder())

  let src = filepath.join(cwd, "../src")

  use name, module <- dict.each(interface.modules)
  use <- bool.guard(name == "lustre/ui", Nil)
  use <- bool.guard(
    !list.is_empty(modules) && !list.contains(modules, name),
    Nil,
  )

  let segments = string.split(name, "/") |> list.map(justin.pascal_case)

  let name = echo string.join(segments, ".") as "Generating..."
  let path = filepath.join(src, string.join(segments, "/") <> ".elm")
  let content = print_module(name, module)

  let assert Ok(_) = simplifile.write(path, content)
  let assert Ok(_) = child_process.exec("elm-format", [".", "--yes"], src)

  Nil
}

// MODULE ----------------------------------------------------------------------

const template = "
module {name} exposing ({exports})

{-| {docs}

## Types

@docs {public_types}

## Elements

@docs {public_elements}

## Attributes

@docs {public_attributes}

## Events

@docs {public_events}

-}

import Html
import Html.Attributes
import Html.Events
import Json.Decode
import Json.Encode

{types}

{functions}
"

fn print_module(name: String, module: Module) -> String {
  let assert Ok(re) =
    regexp.compile(
      "(<script>[\\s\\S]*?</script>|<!--[\\s\\S]*?->)",
      regexp.Options(case_insensitive: True, multi_line: False),
    )

  let docs =
    module.documentation
    |> list.map(string.remove_prefix(_, " "))
    |> string.join("\n")
    |> regexp.replace(re, _, "")
    |> string.trim_start

  let exports = extract_exports(string.join(module.documentation, "\n"))

  template
  |> string.replace("{name}", name)
  |> string.replace("{exports}", print_exports(exports, module.types))
  |> string.replace("{docs}", docs)
  |> string.replace(
    "{public_types}",
    string.join(dict.keys(module.types), ", "),
  )
  |> string.replace("{public_elements}", string.join(exports.elements, ", "))
  |> string.replace(
    "{public_attributes}",
    string.join(exports.attributes, ", "),
  )
  |> string.replace("{public_events}", string.join(exports.events, ", "))
  |> string.replace("{types}", print_types(module.types, name))
  |> string.replace("{functions}", print_functions(module.functions, name))
  |> string.trim_start
}

type Exports {
  Exports(
    elements: List(String),
    attributes: List(String),
    events: List(String),
  )
}

fn extract_exports(documentation: String) -> Exports {
  let assert Ok(re) = regexp.from_string("functions: \\[([\\s\\S]*?)\\]")
  let assert [elements, attributes, events] =
    regexp.scan(re, documentation)
    |> list.map(fn(match) {
      match.submatches
      |> list.filter_map(option.to_result(_, Nil))
      |> string.join("")
      |> string.replace(" ", "")
      |> string.replace("\"", "")
      |> string.replace(",", "")
      |> string.trim
      |> string.split("\n")
      |> list.filter(fn(declaration) {
        declaration != "main" && declaration != "register"
      })
    })

  Exports(elements:, attributes:, events:)
}

fn print_exports(
  exports: Exports,
  types: Dict(String, TypeDefinition),
) -> String {
  let types =
    dict.fold(types, [], fn(types, name, definition) {
      case definition.constructors {
        [] -> [name, ..types]
        _ -> [name <> "(..)", ..types]
      }
    })

  [types, exports.elements, exports.attributes, exports.events]
  |> list.flatten
  |> string.join(", ")
}

//  TYPES ----------------------------------------------------------------------

const type_template = "
{-| {docs} -}
type {name} {generics} = {constructors}
"

fn print_types(
  definitions: Dict(String, TypeDefinition),
  this: String,
) -> String {
  use out, name, definition <- dict.fold(definitions, "")
  let generics =
    bool.guard(definition.parameters == 0, "", fn() {
      int.range(0, definition.parameters, "", fn(generics, n) {
        generics <> print_type_variable(n) <> " "
      })
    })

  let constructors = case definition.constructors {
    [] -> "REPLACE_ME"
    constructors ->
      constructors
      |> list.map(print_type_constructor(_, this))
      |> string.join(" | ")
  }

  let content =
    type_template
    |> string.replace("{docs}", option.unwrap(definition.documentation, ""))
    |> string.replace("{name}", name)
    |> string.replace("{generics}", generics)
    |> string.replace("{constructors}", constructors)

  out <> content <> "\n\n"
}

fn print_type_constructor(t: TypeConstructor, this: String) -> String {
  use <- bool.guard(list.is_empty(t.parameters), t.name)
  use <- bool.lazy_guard(
    list.all(t.parameters, fn(parameter) { option.is_some(parameter.label) }),
    fn() {
      let fields =
        list.map(t.parameters, fn(parameter) {
          let assert option.Some(label) = parameter.label

          label <> " : " <> print_type(parameter.type_, this)
        })

      t.name <> " { " <> string.join(fields, ", ") <> " }"
    },
  )

  let parameters =
    list.map(t.parameters, fn(parameter) { print_type(parameter.type_, this) })

  t.name <> string.join(parameters, ", ")
}

fn print_type(t: Type, this: String) -> String {
  case t {
    Tuple(elements:) ->
      "(" <> string.join(list.map(elements, print_type(_, this)), ", ") <> ")"

    Fn(parameters:, return:) ->
      "(("
      <> string.join(list.map(parameters, print_type(_, this)), ", ")
      <> ") -> "
      <> print_type(return, this)
      <> ")"

    Variable(id:) -> print_type_variable(id)

    Named(name: "Bool", ..) -> "Bool"

    Named(name: "Dict", parameters: [k, v], ..) ->
      "(Dict " <> print_type(k, this) <> " " <> print_type(v, this) <> ")"

    Named(name: "Float", ..) -> "Float"

    Named(name: "Int", ..) -> "Int"

    Named(name: "List", parameters: [a], ..) ->
      "(List " <> print_type(a, this) <> ")"

    Named(name: "Nil", ..) -> "()"

    Named(name: "Option", parameters: [a], ..) ->
      "(Maybe " <> print_type(a, this) <> ")"

    Named(name: "Result", parameters: [a, e], ..) ->
      "(Result " <> print_type(e, this) <> " " <> print_type(a, this) <> ")"

    Named(name: "String", ..) -> "String"

    Named(name: "Attribute", parameters: [a], ..) ->
      "(Html.Attribute " <> print_type(a, this) <> ")"

    Named(name: "Element", parameters: [a], ..) ->
      "(Html.Html " <> print_type(a, this) <> ")"

    Named(name:, package: "lustre_ui", module:, parameters:) -> {
      let module =
        string.split(module, "/")
        |> list.map(justin.pascal_case)
        |> string.join(".")
      let name = case module == this {
        True -> name
        False -> module <> "." <> name
      }

      let parameters =
        parameters
        |> list.map(print_type(_, this))
        |> string.join(", ")

      "(" <> name <> " " <> parameters <> ")"
    }

    Named(..) -> panic
  }
}

fn print_type_variable(id: Int) -> String {
  let assert Ok(codepoint) = string.utf_codepoint(97 + id)

  string.from_utf_codepoints([codepoint])
}

// FUNCTIONS -------------------------------------------------------------------

const function_template = "
{-| {docs} -}
{name} : {type}
{name} {arguments} = Debug.todo \"\"
"

fn print_functions(
  declarations: Dict(String, Function),
  this: String,
) -> String {
  use out, name, declaration <- dict.fold(declarations, "")
  use <- bool.guard(name == "main", out)
  use <- bool.guard(name == "register", out)

  let documentation =
    declaration.documentation
    |> option.unwrap("")
    |> string.split("\n")
    |> list.map(string.remove_prefix(_, " "))
    |> string.join("\n")

  let type_ =
    list.map(declaration.parameters, fn(parameter) {
      print_type(parameter.type_, this)
    })
    |> list.append([print_type(declaration.return, this)])
    |> string.join(" -> ")

  let arguments =
    list.index_map(declaration.parameters, fn(parameter, id) {
      case parameter.label {
        option.Some(label) -> label
        option.None -> print_type_variable(id)
      }
    })
    |> string.join(" ")

  let content =
    function_template
    |> string.replace("{docs}", documentation)
    |> string.replace("{name}", justin.camel_case(name))
    |> string.replace("{type}", type_)
    |> string.replace("{arguments}", arguments)

  out <> content <> "\n\n"
}
