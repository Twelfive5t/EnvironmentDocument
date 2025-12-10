#!/bin/bash
# ACRN RTOS SonarQube 扫描脚本示例
# 
# 使用方法:
# 1. 将此脚本复制到项目根目录
# 2. 确保已创建 sonar-project.properties 文件
# 3. 替换 SONAR_TOKEN 为实际的 token
# 4. 运行: ./sonar-scan.sh

# SonarQube Token (从 http://localhost:9000/account/security 生成)
SONAR_TOKEN="sqa_6d2a4615ea4cb2f52a4130b5032d516ea5939d08"

# 宿主机 IP (根据实际情况修改)
HOST_IP="172.22.158.95"

echo "开始 SonarQube 代码扫描..."
echo "项目目录: $(pwd)"
echo ""

docker run --rm \
  --user root \
  -v "$(pwd):/usr/src" \
  -e SONAR_HOST_URL=http://${HOST_IP}:9000 \
  -e SONAR_TOKEN="${SONAR_TOKEN}" \
  sonarsource/sonar-scanner-cli:latest

EXIT_CODE=$?

echo ""
if [ $EXIT_CODE -eq 0 ]; then
  echo "✅ 扫描完成！查看结果："
  echo "   http://localhost:9000/dashboard?id=acrn_rtos"
else
  echo "❌ 扫描失败，退出码: $EXIT_CODE"
  echo "请检查日志排查问题"
fi

exit $EXIT_CODE
