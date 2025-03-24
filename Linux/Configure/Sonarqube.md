# SonarQube 配置指南

## 目录

- [SonarQube 配置指南](#sonarqube-配置指南)
  - [目录](#目录)
  - [准备工作](#准备工作)
  - [创建 Docker Compose 配置](#创建-docker-compose-配置)
  - [创建必要的目录结构](#创建必要的目录结构)
  - [配置 SonarQube](#配置-sonarqube)
  - [系统配置](#系统配置)
  - [启动服务](#启动服务)
  - [使用 SonarScanner 进行代码扫描](#使用-sonarscanner-进行代码扫描)

## 准备工作

从以下网址下载所需的插件：

- SonarCXX 插件: [https://github.com/SonarOpenCommunity/sonar-cxx/releases](https://github.com/SonarOpenCommunity/sonar-cxx/releases)
- 社区分支插件: [https://github.com/mc1arke/sonarqube-community-branch-plugin/releases](https://github.com/mc1arke/sonarqube-community-branch-plugin/releases)

## 创建 Docker Compose 配置

创建 `docker-compose.yaml` 文件，内容如下：

```yaml
version: "3"

services:
  sonarqube:
    image: sonarqube:lts
    container_name: sonarqube
    depends_on:
      - db
    ports:
      - 9000:9000
    networks:
      - sonarnet
    environment:
      SONARQUBE_JDBC_URL: jdbc:postgresql://db:5432/sonar
      SONARQUBE_JDBC_USERNAME: sonar
      SONARQUBE_JDBC_PASSWORD: sonar
    volumes:
      - ./sonarqube/conf:/opt/sonarqube/conf
      - ./sonarqube/data:/opt/sonarqube/data
      - ./sonarqube/extensions:/opt/sonarqube/extensions
      - ./sonarqube/lib/bundled-plugins:/opt/sonarqube/lib/bundled-plugins
      - ./sonarqube-community-branch-plugin-1.14.0.jar:/opt/sonarqube/extensions/plugins/sonarqube-community-branch-plugin.jar
      - ./sonarqube-community-branch-plugin-1.14.0.jar:/opt/sonarqube/lib/common/sonarqube-community-branch-plugin.jar
      - ./sonar-cxx-plugin-2.2.0.1110.jar:/opt/sonarqube/extensions/plugins/sonar-cxx-plugin.jar
      - ./sonar-cxx-plugin-2.2.0.1110.jar:/opt/sonarqube/lib/common/sonar-cxx-plugin.jar

  db:
    image: postgres
    container_name: postgres
    networks:
      - sonarnet
    environment:
      POSTGRES_USER: sonar
      POSTGRES_PASSWORD: sonar
      POSTGRES_DB: sonar
    volumes:
      - ./postgresql:/var/lib/postgresql
      - ./postgresql/data:/var/lib/postgresql/data

networks:
  sonarnet:
    driver: bridge
```

## 创建必要的目录结构

将下载的插件 JAR 文件和 `docker-compose.yaml` 文件放到 `/root/server/sonar` 目录下，然后在该目录下执行以下命令创建必要的目录：

```bash
# 创建 SonarQube 所需目录
mkdir -p ./sonarqube/conf
mkdir -p ./sonarqube/data
mkdir -p ./sonarqube/extensions
mkdir -p ./sonarqube/lib/bundled-plugins

# 创建 PostgreSQL 数据目录
mkdir -p ./postgresql/data

# 设置正确的权限
chmod 777 -R postgresql
chmod 777 -R sonarqube
```

## 配置 SonarQube

创建 `sonar.properties` 文件并放到 `./sonarqube/conf` 目录下，内容如下：

```properties
sonar.web.javaAdditionalOpts=-javaagent:./extensions/plugins/sonarqube-community-branch-plugin.jar=web
sonar.ce.javaAdditionalOpts=-javaagent:./extensions/plugins/sonarqube-community-branch-plugin.jar=ce

sonar.jdbc.url=jdbc:postgresql://db:5432/sonar?currentSchema=public
sonar.jdbc.username=sonar
sonar.jdbc.password=sonar
```

## 系统配置

SonarQube 需要增加系统可用内存区域，执行以下命令进行永久修改：

```bash
# 编辑系统配置文件
vim /etc/sysctl.conf

# 在文件末尾添加以下内容
vm.max_map_count=262144

# 使配置生效
sysctl -p
```

## 启动服务

在包含 `docker-compose.yaml` 的目录中执行以下命令启动服务：

```bash
docker compose up -d
```

服务启动后，可通过以下地址访问 SonarQube 界面：

```html
http://172.24.255.78:9000/
```

默认登录凭据：

- 用户名: admin
- 密码: admin

首次登录时，系统会要求您更改密码。

## 使用 SonarScanner 进行代码扫描

在需要分析的项目根目录中创建 `sonar-project.properties` 文件，配置扫描参数。

执行以下命令启动代码扫描：

```bash
docker run -it \
  --rm \
  -v $PWD:/usr/src \
  sonarsource/sonar-scanner-cli:latest \
  -Dsonar.projectKey=SonarTest \
  -Dsonar.host.url=http://172.24.255.78:9000 \
  -Dsonar.login=sqp_574debc8709045335baef2b45612b08e700db804
```

> **注意**：请确保替换上述命令中的 token 为您自己从 SonarQube 界面生成的访问令牌。
