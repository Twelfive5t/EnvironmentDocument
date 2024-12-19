> linux安装gtest

    git clone https://github.com/google/googletest.git
    cd googletest
    mkdir build
    cd build
    cmake ..
    make -j16
    make install



> CMake启用覆盖率选项并链接

    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fprofile-arcs -ftest-coverage -g")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fprofile-arcs -ftest-coverage -g")


    target_link_libraries(${PROJECT_NAME} PUBLIC
            gtest
            gtest_main
            gmock
            gmock_main
            gcov
    )

> 使用gcov获取代码覆盖率

    lcov --capture --directory /home/liuyijie/Downloads/rnb_linux_3568/examples/RtosMotionAcrn/build/ --output-file coverage.info

> 去除不必要的系统库的覆盖率

    lcov --remove coverage.info '/usr/include/*' --output-file coverage_filtered.info
    lcov --remove coverage_filtered.info '/usr/local/include/gmock/*' --output-file coverage_filtered.info
    lcov --remove coverage_filtered.info '/usr/local/include/gtest/*' --output-file coverage_filtered.info

> 生成html文件利于查看

    genhtml coverage.info --output-directory coverage