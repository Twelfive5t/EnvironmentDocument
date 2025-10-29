from conan import ConanFile
from conan.tools.files import copy
from conan.tools.cmake import CMake, cmake_layout, CMakeToolchain
from pathlib import Path
from os import path

class AcrnRtosConanFile(ConanFile):
    name = "acrn_rtos"
    user = "rtos"
    version = "0.0.1"
    channel = "acrn"
    description = "acrn_rtos"

    settings = "os", "arch", "compiler", "build_type"
    generators = "CMakeDeps"

    # The requirements() method is used to specify the dependencies of a package.
    # https://docs.conan.io/2.0/reference/conanfile/methods/requirements.html
    def requirements(self):
        self.requires("gtest/1.14.0@third_party/acrn")
        self.requires("bcrobotics/2.0.1@kdc/acrn")
        self.requires("eigen/3.4.0@third_party/acrn")

    # The cmake_layout() sets the folders and cpp attributes to follow the structure of a typical CMake project.
    # https://docs.conan.io/2.0/reference/tools/cmake/cmake_layout.html
    def layout(self):
        cmake_layout(self)
        self.folders.generators = path.join("build", "generators")

    # The purpose of generate() is to prepare the build, generating the necessary files.
    # https://docs.conan.io/2.0/reference/conanfile/methods/generate.html
    def generate(self):
        tc = CMakeToolchain(self)
        tc.user_presets_path = False
        # 定义需要配置 CMAKE 变量的依赖项列表
        # 只有在这个列表中的依赖项才会执行 for 循环配置
        packages_to_configure = ["bcrobotics"]  # 可以根据需要添加更多包名，如 ["bcrobot", "abclib"]
        # set pkg_DIR variable to let cmake load dependent packgae's cmake config files.
        for k, v in self.dependencies._data.items():
            pkg = str(v)[:str(v).find('/')]
            # 只处理列表中指定的包
            if pkg not in packages_to_configure:
                continue
            # when export package to conan, we should set the description with proper name
            # the exported package's cmake folder should contains ${description}Config.cmake
            pkg_name = str(self.dependencies[pkg].description)
            tc.variables[pkg_name + "_DIR"] = Path(
                path.join(self.dependencies[pkg].package_folder, "cmake")).as_posix()
        tc.generate()

    # The build() method is used to define the build from source of the package.
    # https://docs.conan.io/2.0/reference/conanfile/methods/build.html
    def build(self):
        cmake = CMake(self)
        cmake.configure()
        cmake.build()

    # The package() method is in charge of copying files from the source_folder and the temporary build_folder to the package_folder
    ## https://docs.conan.io/2/reference/conanfile/methods/package.html#
    def package(self):
        cmake = CMake(self)
        cmake.install()
