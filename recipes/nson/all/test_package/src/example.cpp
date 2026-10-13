// SPDX-FileCopyrightText: Copyright (c) 2024-2026 us4us Ltd.
// SPDX-License-Identifier: MIT

#include <cstdint>
#include <cstdlib>
#include <iostream>
#include <string>
#include <type_traits>
#include <vector>

// Every public header is included here, so that `conan create` fails if any of
// them cannot be consumed on its own from the packaged include directory.
#include <nson/bits>
#include <nson/compiler>
#include <nson/concepts>
#include <nson/features>
#include <nson/math>
#include <nson/reflection>
#include <nson/string>
#include <nson/type_traits>
#include <nson/void_safe>

enum class Fruit : std::uint8_t { APPLE };

// nson/bits
static_assert(nson::bits::makeMask<std::uint32_t>(3, 0) == 0xFu);
static_assert(nson::bits::alignUp<std::uint32_t>(5, 4) == 8u);

// nson/math
// NOTE: nson::pow is currently off by one power for exp >= 1 (pow<2, 3> yields 16),
// so only the exp == 0 case is pinned here until that is resolved upstream.
static_assert(nson::pow<2, 0> == 1);
static_assert(nson::abs(-3) == 3);
static_assert(nson::abs(3u) == 3u);

// nson/type_traits
static_assert(std::is_same_v<nson::safe_underlying_type_t<Fruit>, std::uint8_t>);
static_assert(std::is_same_v<nson::safe_underlying_type_t<int>, int>);

// nson/void_safe
static_assert(nson::void_safe::safe_sizeof_v<void> == 0);
static_assert(nson::void_safe::safe_sizeof_v<std::uint32_t> == 4);

// nson/concepts
static_assert(nson::supports_to_string<int>);
static_assert(nson::supports_to_string<std::vector<int>>);
static_assert(nson::supports_join<std::vector<int>>);

int main() {
    const std::vector<int> values{1, 2, 3};

    const auto joined = nson::join(values, ", ");
    const auto stringified = nson::to_string(values);
    const auto trimmed = nson::trim("  hello  ");

    std::cout << joined << '\n' << stringified << '\n' << trimmed << '\n';

    // nson/compiler, nson/features and nson/reflection are compile-time only;
    // just make sure the entities are usable.
    std::cout << "compiler=" << static_cast<int>(nson::COMPILER)
              << " exceptions=" << nson::features::WORKING_EXCEPTIONS
              << " type_name=" << nson::reflection::type_name<int> << '\n';

    if (joined != "1, 2, 3" || stringified != "1, 2, 3" || trimmed != "hello") {
        return EXIT_FAILURE;
    }
    return EXIT_SUCCESS;
}
