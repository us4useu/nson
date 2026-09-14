# SPDX-FileCopyrightText: Copyright (c) 2024-2026 us4us Ltd.
# SPDX-License-Identifier: MIT

import os

from conan import ConanFile
from conan.tools.build import check_min_cppstd
from conan.tools.files import copy
from conan.tools.layout import basic_layout
from conan.tools.scm import Git


class NsonConan(ConanFile):
    name = "nson"
    license = "MIT"
    author = "us4us Ltd"
    url = "https://github.com/us4useu/nson"
    homepage = "https://github.com/us4useu/nson"
    description = "us4us C++ standard library extension (header-only)"
    topics = ("cpp", "header-only", "utility", "us4us")

    package_type = "header-library"
    settings = "os", "arch", "compiler", "build_type"
    no_copy_source = True

    @property
    def _min_cppstd(self):
        return "23"

    def layout(self):
        basic_layout(self)

    def export_sources(self):
        repo_root = os.path.abspath(os.path.join(self.recipe_folder, "..", "..", ".."))
        headers = os.path.join(repo_root, "nson")
        if not os.path.isdir(headers):
            return
        copy(self, "*", src=headers,
             dst=os.path.join(self.export_sources_folder, "nson"))
        license_file = os.path.join(repo_root, "LICENSE")
        if os.path.isfile(license_file):
            copy(self, "LICENSE", src=repo_root,
                 dst=self.export_sources_folder)

    def source(self):
        if os.path.isdir(os.path.join(self.source_folder, "nson")):
            return
        sources = self.conan_data["sources"][self.version]
        git = Git(self)
        git.clone(url=sources["url"], target=".")
        git.checkout(sources["commit"])

    def validate(self):
        check_min_cppstd(self, self._min_cppstd)

    def package_id(self):
        # Header-only
        self.info.clear()

    def package(self):
        copy(self, "*",
             src=os.path.join(self.source_folder, "nson"),
             dst=os.path.join(self.package_folder, "include", "nson"))
        license_file = os.path.join(self.source_folder, "LICENSE")
        if os.path.isfile(license_file):
            copy(self, "LICENSE", src=self.source_folder,
                 dst=os.path.join(self.package_folder, "licenses"))

    def package_info(self):
        self.cpp_info.bindirs = []
        self.cpp_info.libdirs = []
        self.cpp_info.includedirs = ["include"]
        self.cpp_info.set_property("cmake_file_name", "nson")
        self.cpp_info.set_property("cmake_target_name", "nson::nson")
