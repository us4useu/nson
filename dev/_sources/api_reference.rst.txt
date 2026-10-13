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
     - Bit manipulation helpers (``nson::bits``): bitmask construction and alignment.
   * - ``nson/compiler``
     - Compile-time detection of the compiler in use (``nson::COMPILER``).
   * - ``nson/concepts``
     - Concepts describing which types ``nson::to_string`` and ``nson::join`` accept.
   * - ``nson/features``
     - Compile-time feature flags for the current toolchain (``nson::features``).
   * - ``nson/math``
     - ``constexpr`` numeric helpers that the standard library lacks, such as integral ``pow``.
   * - ``nson/reflection``
     - Compile-time type names (``nson::reflection::type_name``).
   * - ``nson/string``
     - String conversion and formatting: ``to_string``, ``join``, ``trim``.
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
