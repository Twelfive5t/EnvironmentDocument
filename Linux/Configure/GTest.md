# 在 Linux 上安装和使用 GTest

## 安装 GTest

1. 克隆 `googletest` 仓库：

    ```bash
    git clone https://github.com/google/googletest.git
    ```

2. 进入 `googletest` 目录：

    ```bash
    cd googletest
    ```

3. 创建并进入构建目录：

    ```bash
    mkdir build
    cd build
    ```

4. 使用 `cmake` 配置构建：

    ```bash
    cmake ..
    ```

5. 编译并安装 GTest：

    ```bash
    make -j16
    make install
    ```

## CMake 启用覆盖率选项并链接

1. 在 `CMakeLists.txt` 中启用覆盖率选项：

    ```cmake
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fprofile-arcs -ftest-coverage -g")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fprofile-arcs -ftest-coverage -g")
    ```

2. 链接所需的库：

    ```cmake
    target_link_libraries(${PROJECT_NAME} PUBLIC
            gtest
            gtest_main
            gmock
            gmock_main
            gcov
    )
    ```

## 使用 gcov 获取代码覆盖率

1. 运行 `lcov` 捕获覆盖率数据：

    ```bash
    lcov --capture --directory /home/liuyijie/Downloads/rnb_linux_3568/examples/RtosMotionAcrn/build/ --output-file coverage.info
    ```

## 去除不必要的系统库覆盖率

1. 去除 `/usr/include/` 下的系统库覆盖率：

    ```bash
    lcov --remove coverage.info '/usr/include/*' --output-file coverage_filtered.info
    ```

2. 去除 `gmock` 和 `gtest` 库的覆盖率：

    ```bash
    lcov --remove coverage_filtered.info '/usr/local/include/gmock/*' --output-file coverage_filtered.info
    lcov --remove coverage_filtered.info '/usr/local/include/gtest/*' --output-file coverage_filtered.info
    ```

## 生成 HTML 文件以便查看

1. 生成 HTML 报告：

    ```bash
    genhtml coverage.info --output-directory coverage
    ```

## vscode 利用LiveServer插件实时查看html

1. 扩展中安装 LiveServer

2. 安装 wslu 工具

    ```bash
    apt install wslu
    ```

## 部署 jenkins 自动单元测试

1. 安装 jenkins

    ```bash
    https://pkg.jenkins.io/debian-stable/
    ```

2. 配置为root用户，`vim /usr/lib/systemd/system/jenkins.service`

    ```bash
    User=root
    Group=root
    ```

3. 重启服务

    ```bash
    systemctl daemon-reload
    systemctl restart jenkins
    ```

4. 查看密码

    ```bash
    cat /var/lib/jenkins/secrets/initialAdminPassword
    ```

## Docker 部署 jenkins 自动单元测试

1. Docker 拉取镜像

    ```bash
    docker pull twelfive5t/my-jenkins:latest
    ```

2. 运行镜像

    ```bash
    docker run --privileged -d --name jenkins \
        -p 8080:8080 -p 50000:50000 \
        -v /home/jenkins_data:/var/jenkins_home \
        -v $(which docker):/usr/bin/docker \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v /sys/class/uio/uio0/device:/sys/class/uio/uio0/device \
        -v /dev/EtherCAT0:/dev/EtherCAT0 \
        -u 0 \
        twelfive5t/my-jenkins:latest
    ```

3. 更新镜像

    ```bash
    docker stop jenkins
    docker rm jenkins
    docker pull twelfive5t/my-jenkins:latest
    docker images
    docker rmi ********
    ```

4. 进入镜像

    ```bash
    docker exec -it jenkins bash
    ```
