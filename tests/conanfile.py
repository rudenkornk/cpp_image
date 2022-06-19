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

    # Patch toolchain file, since default generator creates erroneous
    # warnings, which cannot be overridden with generate() function
    def _patch_toolchain_file(self, toolchain_file: str):
        with open(toolchain_file, "r") as f:
            contents = f.read()
        contents = re.sub(r'message\(FATAL_ERROR.*?CMP0091.*', "", contents)
        with open(toolchain_file, "w") as f:
            f.write(contents)

    def generate(self):
        CMakeDeps(self).generate()

        tc = CMakeToolchain(self)
        toolchain_file = tc._conanfile.conf.get(
            "tools.cmake.cmaketoolchain:toolchain_file") or tc.filename
        tc.generate()
        self._patch_toolchain_file(toolchain_file)

    def build(self):
        cmake = CMake(self)
        toolchain_file = os.path.join(
            cmake._conanfile.install_folder, "conan_toolchain.cmake")
        args = [
            "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON",
            "-DCMAKE_TOOLCHAIN_FILE={}".format(toolchain_file),
        ]
        cmake.configure(args=args)
        cmake.build()

