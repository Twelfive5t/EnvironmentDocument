# 在 Linux 上安装和使用 GTest

## 目录

- [在 Linux 上安装和使用 GTest](#在-linux-上安装和使用-gtest)
  - [目录](#目录)
  - [安装 GTest](#安装-gtest)
  - [CMake 配置与链接](#cmake-配置与链接)
  - [代码覆盖率分析](#代码覆盖率分析)
  - [VSCode 实时查看结果](#vscode-实时查看结果)
  - [Jenkins 自动化测试](#jenkins-自动化测试)
  - [Docker 部署 Jenkins](#docker-部署-jenkins)
  - [常见问题与解决方案](#常见问题与解决方案)
  - [参考资源](#参考资源)

## 安装 GTest

- 克隆 `googletest` 仓库：

```bash
git clone https://github.com/google/googletest.git
cd googletest
mkdir build
cd build
cmake ..
make -j$(nproc)
sudo make install
```

## CMake 配置与链接

- 在 `CMakeLists.txt` 中启用覆盖率选项：

```cmake
# 添加代码覆盖率编译选项
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fprofile-arcs -ftest-coverage -g")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fprofile-arcs -ftest-coverage -g")
```

- 链接所需的库：

```cmake
# 链接GTest相关库和覆盖率工具
target_link_libraries(${PROJECT_NAME} PUBLIC
        gtest        # Google Test核心库
        gtest_main   # 提供main函数的GTest库
        gmock        # Google Mock框架
        gmock_main   # 提供main函数的GMock库
        gcov         # GNU代码覆盖率工具
)
```

## 代码覆盖率分析

- 运行测试后，使用 `lcov` 捕获覆盖率数据：

```bash
# 从指定目录捕获覆盖率数据
lcov --capture --directory /path/to/your/build/directory/ --output-file coverage.info
```

- 去除不必要的系统库覆盖率：

```bash
# 过滤掉系统库的覆盖率数据
lcov --remove coverage.info '/usr/include/*' --output-file coverage_filtered.info

# 过滤掉测试框架自身的覆盖率数据
lcov --remove coverage_filtered.info '/usr/local/include/gmock/*' --output-file coverage_filtered.info
lcov --remove coverage_filtered.info '/usr/local/include/gtest/*' --output-file coverage_filtered.info
```

- 生成 HTML 报告：

```bash
# 生成可视化HTML报告
genhtml coverage_filtered.info --output-directory coverage_report
```

## VSCode 实时查看结果

1. 在 VSCode 扩展商店中安装 LiveServer 插件

2. 安装 wslu 工具（适用于WSL用户）：

    ```bash
    sudo apt install wslu
    ```

3. 右击覆盖率报告中的index.html文件，选择"Open with Live Server"

## Jenkins 自动化测试

1. 安装 Jenkins：

    ```bash
    # 添加Jenkins存储库密钥
    wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -

    # 添加Jenkins存储库
    sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'

    # 更新软件包列表并安装Jenkins
    sudo apt update
    sudo apt install jenkins
    ```

2. 配置为root用户（如有必要）：

    ```bash
    sudo vim /usr/lib/systemd/system/jenkins.service
    # 修改以下行
    User=root
    Group=root
    ```

3. 重启服务：

    ```bash
    sudo systemctl daemon-reload
    sudo systemctl restart jenkins
    ```

4. 获取初始管理员密码：

    ```bash
    sudo cat /var/lib/jenkins/secrets/initialAdminPassword
    ```

## Docker 部署 Jenkins

- Docker 拉取镜像：

```bash
docker pull twelfive5t/my-jenkins:latest
```

- 运行 Jenkins 容器：

```yaml
version: '3.8'

services:
  jenkins:
    container_name: jenkins
    image: harbor.fscut.com/rtos/jenkins:latest
    privileged: true
    ports:
      - "8080:8080"
      - "50000:50000"
    volumes:
      - /home/jenkins_data:/var/jenkins_home
      - /usr/bin/docker:/usr/bin/docker
      - /var/run/docker.sock:/var/run/docker.sock
      - /sys/class/uio/uio0/device:/sys/class/uio/uio0/device
      - /dev/EtherCAT0:/dev/EtherCAT0
    user: "0"
    restart: unless-stopped

```

- 管理 Jenkins 容器：

```bash
# 停止容器
docker stop jenkins

# 移除容器
docker rm jenkins

# 更新镜像
docker pull twelfive5t/my-jenkins:latest

# 查看镜像列表
docker images

# 移除旧镜像（替换********为实际的镜像ID）
docker rmi ********

# 进入容器命令行
docker exec -it jenkins bash
```

## 常见问题与解决方案

1. GTest安装失败：检查CMake版本和编译器是否支持
2. 覆盖率数据不完整：确保使用正确的构建目录路径
3. Jenkins权限问题：确认用户权限和文件访问设置

## 参考资源

- [GTest 官方文档](https://google.github.io/googletest/)
- [Jenkins 官方文档](https://www.jenkins.io/doc/)
- [LCOV 代码覆盖率工具](http://ltp.sourceforge.net/coverage/lcov.php)
