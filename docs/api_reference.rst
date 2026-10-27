API Reference
=============

The public API are located entirely in the ``nson`` namespace.

Public headers
--------------

Every header is extensionless and included as ``#include <nson/name>``.

.. list-table::
   :header-rows: 1
   :widths: 25 75

   * - Header
     - Contents
   * - ``nson/bits``
     - Bit manipulation helpers (``nson::bits::*``).
   * - ``nson/char_array``
     - A modern, fully-compatible replacement for C-style string literals (``nson::char_array``).
   * - ``nson/compiler``
     - Compile-time detection of the compiler in use (``nson::COMPILER`` and ``nson::COMPILER_SPECIFIC``).
   * - ``nson/concepts``
     - Concepts describing which types ``nson::to_string`` and ``nson::join`` accept.
   * - ``nson/console``
     - A safe, consistent rich console output library (``nson::cout``) as well as control sequences (``nson::xterm::*``)
   * - ``nson/features``
     - Compile-time feature flags for the current toolchain (``nson::features::*``).
   * - ``nson/math``
     - ``constexpr`` numeric helpers that the standard library lacks, such as integral ``pow``.
   * - ``nson/platform``
     - Compile-time detection of the platform in use (``nson::PLATFORM``, ``nson::IS_WINDOWS``, ``nson::IS_LINUX``).
   * - ``nson/reflection``
     - Compile-time type names (``nson::reflection::type_name``).
   * - ``nson/string``
     - String conversion and formatting: ``to_string``, ``join``, ``trim``.
   * - ``nson/tui``
     - A data-driven terminal user interface (TUI) library.
   * - ``nson/type_traits``
     - Assorted type traits, such as ``safe_underlying_type``.
   * - ``nson/void_safe``
     - Type traits that tolerate ``void`` (``nson::void_safe``).

Reference
---------

.. doxygennamespace:: nson
   :project: nson
   :members:
   :undoc-members:
