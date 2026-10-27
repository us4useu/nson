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
  `std::formattable`, deducing this (please use it!) and other C++20/23 features.
- Public APIs generally live in the `nson` namespace, while implementation helpers live in
  `nson::internal::<subsystem>`, however it's all up to your judgement. 
- Functions and methods use `camelCase` (e.g. `makeMask`, `alignUp`). This is
  enforced by `.clang-tidy` in CI, which fails the build on a violation; run it
  locally with:
  ```
  clang-tidy nson/<header> -- -std=c++23 -x c++ -I.
  ```
  The `to_string` overloads are the one deliberate exception, marked with
  `NOLINT`, because they mimic `std::to_string`. Concepts, type traits, and
  variable templates keep `snake_case`, matching the standard library.
- Use `#pragma once` in headers. Do not use include guards.
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
- Always use common sense and your own judgement to make decisions about style and design - rules are not absolute and can be bent if it makes sense to do so.
- Try to avoid using preprocessor macros. Sadly, sometimes they are unavoidable, but to keep tidy conform to the following rules:
  - Use our own local macros, as defined in `nson/features`, `nson/compiler` and `nson/platform` instead of using the compiler's/OS's macros directly. If the aforementioned files don't have a macro for your use case, it's up to you to add it.
  - *Generally* avoid using macros outside of the internal implementations.
  - *Generally* macros should only be used for conditional compilation for a specific platform/environment/etc. For other purposes, try using `constexpr` variables, `inline` functions, or templates instead.
- `nson` is also sometimes used for driver code, without the full C++/STL support. Obviously, sometimes the headers here are meant for a full desktop environment (i.e. `<nson/console>`), but try to avoid making code unnecessarily dependent on the STL where possible. See `<nson/char_array>` for an example of how to make a header that works with `std::string` where possible, without having a hard dependency on it.
  - Currently the rule is kind-of "vibes" based; in the future, we might align to the freestanding C++26 spec. However, generally try to avoid:
    - `std::string`;
    - Anything floating-point;
    - Exceptions (!);
    - RTTI (see `<nson/reflection>` for how we can use compile-time expressions to avoid it);
  - Internal us4us devs: generally strive to make the code usable when hosted by `rose-rt`.

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