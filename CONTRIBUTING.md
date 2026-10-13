# Contributing to Nson

Thanks for your interest in contributing! This document describes how to build
the library, the conventions we follow, and how to propose changes.

## Reporting issues

- Use the GitHub issue tracker to report bugs, request features, or ask
  questions about the library.
- When reporting a bug, please include:
  - a minimal reproducer (a short `.cpp` file is ideal),
  - your compiler and its version,
  - the version of Nson you are using,
  - the observed behavior and what you expected instead.

## Development setup

Nson is a header-only C++23 library packaged with
[Conan 2](https://conan.io/). To hack on it locally:

1. Clone the repository:
   ```
   git clone https://github.com/us4useu/nson.git
   cd nson
   ```

2. Export the recipe into your local Conan cache so downstream projects can
   consume your working copy:
   ```
   conan export recipes/nson/all --version=vA.B.i
   ```

3. In a consumer project, add `nson/0.1.0` to your `conanfile.txt` (or
   `conanfile.py`) and rebuild.

Because the library is header-only, most changes only require re-exporting the
recipe; the repository itself has nothing to build.

## Building the documentation

The documentation is generated with Sphinx + Doxygen + Breathe. Prerequisites:

- `doxygen` (1.9+ recommended)
- Python 3.9+ with the packages listed in `docs/requirements.txt`

From the repository root:

```
pip install -r docs/requirements.txt
make -C docs html
```

The generated HTML lands in `docs/_build/html/`. Open
`docs/_build/html/index.html` in a browser to preview.

## Coding conventions

- Target C++23. It is fine to use `<concepts>`, `<ranges>`, `<format>`,
  `std::formattable`, and other C++20/23 features.
- Public APIs live in the `nson` namespace. Implementation helpers live in
  `nson::internal::<subsystem>`.
- Functions and methods use `camelCase` (e.g. `makeMask`, `alignUp`). This is
  enforced by `.clang-tidy` in CI, which fails the build on a violation; run it
  locally with:
  ```
  clang-tidy nson/<header> -- -std=c++23 -x c++ -I.
  ```
  The `to_string` overloads are the one deliberate exception, marked with
  `NOLINT`, because they mimic `std::to_string`. Concepts, type traits, and
  variable templates keep `snake_case`, matching the standard library.
- Header guards use the `NSON_<PATH>_H` form (e.g. `NSON_STRING_H`).
- Every source file starts with the SPDX header:
  ```
  // SPDX-FileCopyrightText: Copyright (c) <year> us4us Ltd.
  // SPDX-License-Identifier: MIT
  ```
- Document public functions and concepts with a short Doxygen-style comment
  describing parameters, return value, and any non-obvious behavior.
- Follow the formatting used in existing headers (4-space indentation, braces
  on the same line, `east const` is not required — match the surrounding
  code).

## Submitting changes

1. Fork the repository and create a topic branch off the current `vA.B.x` branch.
2. Make your changes in small, focused commits with clear commit messages.
3. Ensure the recipe still exports cleanly:
   ```
   conan export recipes/nson/all --version=vA.B.i
   ```
4. Open a pull request against the current `vA.B.x` branch describing the motivation for the
   change and any user-visible impact.

## License

By contributing, you agree that your contributions will be licensed under the
MIT license, the same license that covers this project. See [LICENSE](LICENSE)
for details.