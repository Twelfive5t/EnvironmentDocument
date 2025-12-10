# SonarQube 快速命令参考

## 服务管理

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
docker compose restart sonarqube
```

### 重启并清理数据（慎用）

```bash
cd /opt/sonarqube
docker compose down
rm -rf sonarqube/data/* postgresql/data/*
docker compose up -d
```

## 日志查看

### 查看 SonarQube 日志

```bash
docker logs sonarqube
docker logs sonarqube --tail 100
docker logs -f sonarqube  # 实时跟踪
```

### 查看 PostgreSQL 日志

```bash
docker logs postgres
docker logs postgres --tail 50
```

## 状态检查

### 检查容器状态

```bash
docker ps | grep -E "sonarqube|postgres"
```

### 检查服务健康状态

```bash
curl http://localhost:9000/api/system/status
```

### 检查版本信息

```bash
docker logs sonarqube 2>&1 | grep "SonarQube Server"
```

## 项目扫描

### 使用扫描脚本

```bash
cd /path/to/your/project
./sonar-scan.sh
```

### 手动运行扫描

```bash
docker run --rm \
  --user root \
  -v "$(pwd):/usr/src" \
  -e SONAR_HOST_URL=http://172.22.158.95:9000 \
  -e SONAR_TOKEN=your_token_here \
  sonarsource/sonar-scanner-cli:latest
```

### 查看扫描结果

```bash
# 浏览器访问
http://localhost:9000/dashboard?id=your_project_key
```

## Token 管理

### 生成 Token（Web UI）

1. 访问: <http://localhost:9000/account/security>
2. 点击 "Generate Token"
3. 输入 Token 名称
4. 选择类型: Global Analysis Token
5. 点击 "Generate"
6. 保存生成的 Token

### 使用 API 生成 Token

```bash
curl -X POST -u admin:admin \
  "http://localhost:9000/api/user_tokens/generate?name=my-token&type=GLOBAL_ANALYSIS_TOKEN"
```

## 配置管理

### 查看 CXX 插件配置

```bash
# Web UI
http://localhost:9000/admin/settings?category=cxx

# API
curl -s "http://localhost:9000/api/settings/values?keys=sonar.cxx.file.suffixes" \
  -u admin:admin
```

### 设置 CXX 文件后缀

```bash
curl -X POST "http://localhost:9000/api/settings/set" \
  -u admin:admin \
  -d "key=sonar.cxx.file.suffixes" \
  -d "values=.cxx,.cpp,.cc,.c,.hxx,.hpp,.hh,.h"
```

## 数据库管理

### 进入 PostgreSQL 容器

```bash
docker exec -it postgres psql -U sonar -d sonar
```

### 查看数据库大小

```bash
docker exec postgres psql -U sonar -d sonar -c \
  "SELECT pg_size_pretty(pg_database_size('sonar'));"
```

### 备份数据库

```bash
docker exec postgres pg_dump -U sonar sonar > sonarqube_backup_$(date +%Y%m%d).sql
```

### 恢复数据库

```bash
docker exec -i postgres psql -U sonar sonar < sonarqube_backup.sql
```

## 故障排查

### 检查端口占用

```bash
netstat -tulnp | grep -E "9000|5432"
```

### 检查磁盘空间

```bash
df -h /opt/sonarqube
```

### 检查内存使用

```bash
docker stats sonarqube postgres
```

### 清理 Docker 资源

```bash
# 清理未使用的镜像
docker image prune -a

# 清理未使用的卷
docker volume prune

# 清理未使用的网络
docker network prune
```

## 插件管理

### 列出已安装的插件

```bash
ls -lh /opt/sonarqube/sonarqube/extensions/plugins/
```

### 查看插件信息

```bash
docker logs sonarqube 2>&1 | grep "Deploy.*Plugin"
```

### 添加新插件

```bash
# 1. 下载插件 jar 文件
# 2. 复制到插件目录
cp plugin.jar /opt/sonarqube/sonarqube/extensions/plugins/
# 3. 重启 SonarQube
cd /opt/sonarqube && docker compose restart sonarqube
```

## 性能优化

### 增加 SonarQube 内存（修改 docker-compose.yaml）

```yaml
sonarqube:
  environment:
    - SONAR_WEB_JAVAADDITIONALOPTS=-Xmx2g -Xms1g
    - SONAR_CE_JAVAADDITIONALOPTS=-Xmx2g -Xms1g
```

### 增加 PostgreSQL 内存

```yaml
postgres:
  command: postgres -c shared_buffers=256MB -c max_connections=200
```

## 网络相关

### 查看 Docker 网络

```bash
docker network ls
docker network inspect sonarqube_default
```

### 获取容器 IP

```bash
docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' sonarqube
docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' postgres
```

## 其他实用命令

### 导出项目配置

```bash
curl "http://localhost:9000/api/settings/values?component=acrn_rtos" \
  -u admin:admin > project_settings.json
```

### 查看项目问题统计

```bash
curl "http://localhost:9000/api/measures/component?component=acrn_rtos&metricKeys=bugs,vulnerabilities,code_smells" \
  -u admin:admin | python3 -m json.tool
```

### 重新分析项目

```bash
# 在项目目录下运行
cd /home/liuyijie/Downloads/acrn_rtos
./sonar-scan.sh
```
