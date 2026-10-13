Installation
============

Requirements
------------

- A C++23-capable compiler (gcc 13+, clang 17+, MSVC 19.37+).
- `Conan 2 <https://conan.io/>`_ or use headers manually.

Conan (recommended)
-----------------------

Add nson to the ``[requires]`` section of your ``conanfile.txt``:

.. code-block:: ini

   [requires]
   nson/0.1.0

Or, in a ``conanfile.py``:

.. code-block:: python

   class MyProject(ConanFile):
       requires = "nson/0.1.0"

Then include the ``nson`` headers:

.. code-block:: cpp

   #include <nson/string>
   #include <nson/concepts>

   #include <iostream>
   #include <vector>

   int main() {
       std::vector<int> values{1, 2, 3};
       std::cout << nson::join(values, ", ") << '\n';   // "1, 2, 3"
       std::cout << nson::to_string(values) << '\n';    // "1, 2, 3"
       std::cout << nson::trim("   hello   ") << '\n';  // "hello"
   }

With CMake, link against the ``nson::nson`` target exposed via Conan's generator:

.. code-block:: cmake

   find_package(nson CONFIG REQUIRED)
   target_link_libraries(my_app PRIVATE nson::nson)

Header-only usage
------------------------------

Download the release archive
(``nson-<version>.zip``) from the
`GitHub Releases <https://github.com/us4useu/nson/releases>`_ page,
extract it, and add the extracted ``nson/`` directory to your include path.
