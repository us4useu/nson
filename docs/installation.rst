Installation
============

Requirements
------------

- A C++23-capable compiler (gcc 13+, clang 17+, MSVC 19.37+).
- `Conan 2 <https://conan.io/>`_ (recommended) or manual header usage.

Via Conan (recommended)
-----------------------

Add nson to the ``[requires]`` section of your ``conanfile.txt``:

.. code-block:: ini

   [requires]
   nson/0.1.0

Or, in a ``conanfile.py``:

.. code-block:: python

   class AcmeProject(ConanFile):
       requires = "nson/0.1.0"

Then include the headers via the ``nson/`` prefix:

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

With CMake, link against the ``nson::nson`` target exposed by Conan's
``CMakeDeps`` generator:

.. code-block:: cmake

   find_package(nson CONFIG REQUIRED)
   target_link_libraries(my_app PRIVATE nson::nson)

Header-only drop-in (no Conan)
------------------------------

Download the release archive
(``nson-<version>.zip``) from the
`GitHub Releases <https://github.com/us4useu/nson/releases>`_ page,
extract it, and add the extracted ``nson/`` directory to your include path:

.. code-block:: cmake

   target_include_directories(my_app PRIVATE path/to/nson-<version>)

Then include headers under the ``nson/`` prefix as shown above.
