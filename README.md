# type-stripper

Python package that strips type annotations from a source file,
printing the modified file to stdout.

## Installation

Install `type-stripper` from [PyPI](https://pypi.org/project/type-stripper/):

```sh
pip install type-stripper
```

You can also run `type-stripper` as a standalone tool using [pipx](https://pipx.pypa.io/):

```sh
# As an installed standalone tool:
pipx install type-stripper

# Or as a one-off:
pipx run type-stripper /path/to/file.py
```

## Usage

Runs as a CLI tool. Give it a file path:

```sh
type-stripper /path/to/file.py
```

...and the results of the changes will be sent to stdout.

This output can be piped back to a file:

```sh
type-stripper /path/to/file.py > newfile.py
```

Use `type-stripper --help` for details.

## What it does

- Parameter annotations in function definitions are removed:

  ```diff
  - def func(a: int, b: str = "30", c: int = 42, *args: str, **kwargs: dict[str, int]):
  + def func(a, b = "30", c = 42, *args, **kwargs):
  ```

- Return-type annotations are removed:

  ```diff
  - def func() -> str:
  + def func():
  ```

- Annotations in variable assignments are removed:

  ```diff
  - x: int = 10
  + x = 10
  ```

- Bare annotation statements are removed entirely:

  ```diff
  - x: int
  ```

Formatting, comments, and all other syntax remains unchanged.

### What it does not do

Some of the resulting code's format may be stylistically incorrect:

```diff
# Given:
- def foo(a: int = 4):

# Produces:
+ def foo(a = 4):

# What it probably should produce (note the spacing):
+ def foo(a=4):
```

You may wish to run results through a formatter first.

## How?

This package uses [`libcst`](https://github.com/Instagram/LibCST)
to parse the Concrete Syntax Tree of an input module,
then modifies (or removes) nodes in that tree to strip type annotations away.

A similar task could be completed in Python's [`ast`](https://docs.python.org/3/library/ast.html) module,
however the AST does not preserve code structure or syntax the way CST does.

## Why?

For fun ~~and profit~~. 🙂

There are some potential use cases, however:

- **Backwards compatibility**:
  Code developed on modern Python versions with type hinting
  may not work on older versions of Python.
  While I would strongly recommend migrating to a more recent version of Python,
  this tool can get code working faster.
- **Other Python variants**:
  Some Python dialects
  (such as [Starlark](https://github.com/bazelbuild/starlark))
  may use the same Python syntax, but may not (now or ever) support type annotations.
  This tool can be used to transpile code meant for more "standard" Python flavors
  to work in these environments.
- **Smaller file size**:
  Need to shave precious bytes off a Docker image build
  and your type hints are not relevant to the runtime
  (i.e., not using FastAPI where type annotations are critical)?
  Strip those type hints off to reduce file sizes to their bare minimum.
- **Reduced complexity when teaching**:
  Modern Python code with type annotations may be difficult
  for the newest beginners to comprehend.
  While teaching how data types interact is important,
  some learners may benefit from the reduced noise in their code samples.

Absolutely none of these statements are qualified or tested:
I just sort of made them up.
Take it as you will!

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md)
