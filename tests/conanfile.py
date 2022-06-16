import os

from conans import ConanFile, CMake
from conan.tools.cmake import CMakeToolchain


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

    generators = "CMakeToolchain", "CMakeDeps"

    def build(self):
        cmake = CMake(self)
        args = [
            "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON",
            "-DCMAKE_TOOLCHAIN_FILE=%s/conan_toolchain.cmake" % cmake._conanfile.build_folder,
        ]
        cmake.configure(args=args)
        cmake.build()
