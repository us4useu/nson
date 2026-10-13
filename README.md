# About Nia Sono 

Nia sono (or `nson` for short) is a header-only collection of C++ classes and functions that extend the
C++ standard library with utilities commonly needed across us4us projects. The
package is developed and used extensively by us4us Ltd in its C++ codebase.

In spirit, this library plays a similar role to Google's [Abseil](https://abseil.io/):
it fills small but recurring gaps in the standard library with focused,
well-tested helpers.

The name "nson" is an abbreviation of "nia sono", which means "our sound" in [Esperanto](https://en.wikipedia.org/wiki/Esperanto).

All headers live in the `nson` namespace and are packaged under the Conan
recipe name `nson`.

You can find documentation here: [stable](https://us4useu.github.io/nson/stable), [dev](https://us4useu.github.io/nson/dev).

# Quick start



Nson is distributed as a header-only library through the
[Conan](https://conan.io/) package manager.

Add `nson/0.1.0` to the `[requires]` section of your `conanfile.txt` (or the
`requires` attribute of your `conanfile.py`):

```
[requires]
nson/0.1.0
```

Then include the headers from the `nson/` directory:

```cpp
#include <nson/string>
#include <nson/concepts>

#include <vector>
#include <iostream>

int main() {
    std::vector<int> values{1, 2, 3};
    std::cout << nson::join(values, ", ") << std::endl;   // "1, 2, 3"
    std::cout << nson::to_string(values) << std::endl;    // "1, 2, 3"
    std::cout << nson::trim("   hello   ") << std::endl;  // "hello"
}
```

Nson requires a C++23-capable compiler.

# Structure

The public API is exposed through the following components:

- `concepts` — Concepts used to constrain templates in the rest of the
  library.
- `string` — String utilities, incliuding a generic `to_string` that works on both
  scalars and ranges, `join` for combining a range of values into a single
  string with a separator, etc.

Headers under `nson/internal/` are implementation details and are not part
of the public API.

# Contributing

Contributions are welcome. Please read [CONTRIBUTING.md](CONTRIBUTING.md)
before opening a pull request — it describes how to build the library, the
coding conventions we follow, and how to add new components.

# License

Nson is licensed under the terms of the MIT license. See [LICENSE](LICENSE)
for more information.

# References

- This project was inspired by Google's [Abseil](https://abseil.io/) library.
- Nson is used extensively in us4us projects, in particular
  [ARRUS](https://github.com/us4useu/arrus).
