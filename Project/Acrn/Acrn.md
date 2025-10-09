# ACRN项目开发文档

## 📚 常用链接

### 官方文档

- [Getting Started Guide](https://projectacrn.github.io/latest/getting-started/getting-started.html#prepare-the-development-computer) - ACRN快速入门指南
- [Sample Application User Guide](https://projectacrn.github.io/latest/getting-started/sample-app.html) - ACRN示例应用程序用户指南

### 代码仓库

- [ACRN Hypervisor](https://github.com/projectacrn/acrn-hypervisor) - ACRN虚拟化程序源代码
- [ACRN Kernel](https://github.com/projectacrn/acrn-kernel.git) - ACRN虚拟化内核源代码

### ECI相关

- [Build ECI Documentation](https://eci.intel.com/docs/3.3/getstarted/building.html) - ECI构建文档
- [Intel Registration Center](https://lemcenter.intel.com/productDownload/?Product=3409) - Intel用户门户

## 🔧 ECI镜像构建

### 前置条件

- **用户权限**: 必须使用非root用户执行构建脚本
- **Docker权限**: 需要将用户添加到docker组，如果权限不足会有提示

### 构建步骤

#### 1. 初始设置

```bash
# 切换到非root用户
# 执行初始设置
./setup.sh
```

#### 2. 修复Ubuntu lunar版本问题

由于Ubuntu lunar版本不再维护，需要手动修改配置：

**修改build_container.sh:**

```bash
# 注释掉以下行
# wget ...
# patch ...
```

**修改kas-4.1/dockerfile:**
添加以下内容到dockerfile中：

```dockerfile
RUN sed -i 's/archive.ubuntu.com/old-releases.ubuntu.com/g' /etc/apt/sources.list && \
    sed -i '/security.ubuntu.com/d' /etc/apt/sources.list
```

#### 3. 选择构建目标

```bash
# 选择core-jammy作为构建目标
```

## 🔍 故障排除

### ROS密钥校验失败问题

**错误信息:**

```info
ERROR: isar-bootstrap-target-1.0-r0 do_fetch: Fetcher failure for URL:
'https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc;md5sum=4d92afe47d6f4f2e97b8ad3a5e905667'.
Checksum mismatch!
File: '/build/downloads/ros.asc' has md5 checksum '240079c853b38689d9f393d36c7289fb'
when '4d92afe47d6f4f2e97b8ad3a5e905667' was expected
```

**解决方案:**
全局搜索并替换校验码：

```bash
# 将旧的md5校验码替换为新的
# 搜索: 4d92afe47d6f4f2e97b8ad3a5e905667
# 替换为: 240079c853b38689d9f393d36c7289fb
```

或者在相关recipe文件中更新校验码：

```bitbake
SRC_URI[sha256sum] = "490a879375bd4f3dfbe1483efbf8db8985e2ad66b7a19baee0087b333c67caf0"
```

## 📝 ACRN配置

详细配置步骤请参考：[Getting Started Guide](https://projectacrn.github.io/latest/getting-started/getting-started.html#prepare-the-development-computer)

## 💡 提示

- 构建过程可能需要较长时间，请耐心等待
- 如遇到其他错误，建议查看构建日志进行排查
- 建议定期更新相关依赖和工具链
