# SonarQube 代码静态分析平台配置文档

## 📋 目录

- [系统信息](#系统信息)
- [部署架构](#部署架构)
- [配置文件](#配置文件)
- [使用说明](#使用说明)
- [项目扫描配置](#项目扫描配置)
- [常见问题](#常见问题)

---

## 系统信息

### 服务版本

- **SonarQube**: 25.11.0.114957 (Community Edition)
- **PostgreSQL**: 13
- **SonarQube CXX Plugin**: 2.2.2.1350

### 服务地址

- **SonarQube Web**: <http://localhost:9000>
- **PostgreSQL**: localhost:5432

### 默认凭证

- **管理员账号**: admin
- **初始密码**: admin (首次登录需修改)

---

## 部署架构

### Docker Compose 部署

采用 Docker Compose 方式部署，包含两个容器：

1. **postgres**: PostgreSQL 数据库
2. **sonarqube**: SonarQube 服务

### 目录结构

```sh
/opt/sonarqube/
├── docker-compose.yaml              # Docker Compose 配置文件
├── sonar-cxx-plugin-2.2.2.1350.jar  # C++ 插件（原始文件）
├── postgresql/
│   └── data/                        # PostgreSQL 数据目录
└── sonarqube/
    ├── data/                        # SonarQube 数据目录
    ├── extensions/
    │   └── plugins/                 # 插件目录
    │       └── sonar-cxx-plugin-2.2.2.1350.jar
    └── logs/                        # 日志目录
```

---

## 配置文件

### 1. docker-compose.yaml

位置: `/opt/sonarqube/docker-compose.yaml`

完整配置请查看: [docker-compose.yaml](./docker-compose.yaml)

关键配置说明：

- **数据持久化**: 使用本地目录挂载
- **环境变量**: 配置数据库连接信息

### 2. SonarQube CXX 插件配置

在 SonarQube Web UI 中配置: <http://localhost:9000/admin/settings?category=cxx>

**重要设置**:

- **File suffixes**: `.cxx,.cpp,.cc,.c,.hxx,.hpp,.hh,.h`
  - ⚠️ 第一个值不能是 `-`，否则会禁用 CXX 语言支持
  ![alt text](CXXFileSuffixes.png)

---

## 使用说明

### 启动服务

```bash
cd /opt/sonarqube
docker compose up -d
```

### 停止服务

```bash
cd /opt/sonarqube
docker compose down
```

### 重启服务

```bash
cd /opt/sonarqube
docker compose restart
```

### 查看日志

```bash
# 查看 SonarQube 日志
docker logs sonarqube

# 查看 PostgreSQL 日志
docker logs postgres

# 实时跟踪日志
docker logs -f sonarqube
```

### 检查服务状态

```bash
# 检查容器状态
docker ps | grep -E "sonarqube|postgres"

# 检查 API 状态
curl http://localhost:9000/api/system/status
```

---

## 项目扫描配置

### ACRN RTOS 项目配置示例

#### sonar-project.properties

位置: `/home/liuyijie/Downloads/acrn_rtos/sonar-project.properties`

```properties
# SonarQube 项目配置
sonar.projectKey=acrn_rtos
sonar.projectName=ACRN_RTOS
sonar.projectVersion=1.0

# SonarQube 服务器地址
sonar.host.url=http://172.22.158.95:9000

# C/C++ 特定配置
sonar.language=cxx
sonar.sourceEncoding=UTF-8

# 源代码目录
sonar.sources=.

# 只包含 C/C++ 源文件和头文件
sonar.inclusions=common/**, examples/**, third_part/Ec_Master_Lib/**

```

#### 扫描脚本

位置: `/home/liuyijie/Downloads/acrn_rtos/sonar-scan.sh`

完整脚本请查看: [sonar-scan.sh](./sonar-scan-example.sh)

### 运行扫描

```bash
cd /home/liuyijie/Downloads/acrn_rtos
./sonar-scan.sh
```

### 查看结果

扫描完成后访问: <http://localhost:9000/dashboard?id=acrn_rtos>

---

## 常见问题

### 1. C++ 文件没有被扫描 (0 languages detected)

**原因**: CXX 插件的 File suffixes 配置错误

**解决方案**:

1. 访问 <http://localhost:9000/admin/settings?category=cxx>
2. 检查 **File suffixes** 设置
3. 确保第一个值不是 `-`，应该是 `.c` 或 `.cpp` 等
4. 正确的配置示例: `.cxx,.cpp,.cc,.c,.hxx,.hpp,.hh,.h`
5. 保存后重新运行扫描

### 2. 容器启动失败

**检查步骤**:

```bash
# 查看容器状态
docker ps -a | grep -E "sonarqube|postgres"

# 查看错误日志
docker logs sonarqube
docker logs postgres

# 检查端口占用
netstat -tulnp | grep -E "9000|5432"
```

### 3. 数据库连接失败

**检查配置**:

- 确认 PostgreSQL 容器正常运行
- 检查 docker-compose.yaml 中的数据库连接配置
- 验证容器间网络连通性

### 4. 扫描时认证失败 (HTTP 401)

**解决方案**:

1. 在 SonarQube Web UI 生成 Token:
   - 访问 <http://localhost:9000/account/security>
   - 生成 Global Analysis Token

2. 在扫描脚本中使用生成的 Token:

```bash
-e SONAR_TOKEN=your_token_here
```

### 5. 版本过期警告

**问题**: "You're running a version of SonarQube that is no longer active"

**解决方案**: 已升级到最新的 Community 版本 (25.11.0)

---

## 维护建议

### 备份

定期备份以下目录:

```bash
# 备份数据库
/opt/sonarqube/postgresql/data/

# 备份 SonarQube 数据
/opt/sonarqube/sonarqube/data/
```

### 升级

升级前务必备份数据，升级步骤:

```bash
cd /opt/sonarqube
docker compose down
# 修改 docker-compose.yaml 中的版本
docker compose pull
docker compose up -d
```

### 日志清理

定期清理旧日志:

```bash
# 清理 SonarQube 日志
rm -rf /opt/sonarqube/sonarqube/logs/*.log.*

# 清理 Docker 日志
docker logs sonarqube 2>&1 | tail -1000 > /tmp/sonarqube.log
```

---

## 参考链接

- [SonarQube 官方文档](https://docs.sonarsource.com/sonarqube/)
- [SonarQube CXX 插件](https://github.com/SonarOpenCommunity/sonar-cxx)
- [Docker Hub - SonarQube](https://hub.docker.com/_/sonarqube)
- [Docker Hub - SonarScanner CLI](https://hub.docker.com/r/sonarsource/sonar-scanner-cli)

---

**文档版本**: 1.0  
**创建日期**: 2025-12-10  
**维护人**: liuyijie
