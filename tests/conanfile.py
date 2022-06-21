import os
import re

from conans import ConanFile, CMake
from conan.tools.cmake import CMakeToolchain
from conan.tools.cmake import CMakeDeps


class HelloWorldConan(ConanFile):
    settings = [
        "arch",
        "build_type",
        "compiler",
        "os",
    ]
    requires = [
        "boost/1.79.0",
    ]

    default_options = {
        "boost:header_only": True,
    }

    generators = []

    def generate(self):
        CMakeDeps(conanfile=self).generate()
        tc = CMakeToolchain(conanfile=self)

        vs_block = tc.blocks["vs_runtime"].template
        vs_block = re.sub(r'\s+message\(FATAL_ERROR.*?CMP0091.*', "", vs_block)
        tc.blocks["vs_runtime"].template = vs_block

        if self.settings.compiler == "gcc":
            tc.variables["CMAKE_C_COMPILER"] = "gcc"
            tc.variables["CMAKE_CXX_COMPILER"] = "g++"
        elif self.settings.compiler == "clang":
            tc.variables["CMAKE_C_COMPILER"] = "clang"
            tc.variables["CMAKE_CXX_COMPILER"] = "clang++"
        tc.generate()

