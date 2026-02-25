#!/bin/bash
# Docker 入口脚本

set -e

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║          EasyMultiProfiler Docker 启动                         ║"
echo "║          R包 + Web 完整环境                                     ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# 检查 R 包
echo "🔬 检查 R 包..."
R -e "library(EasyMultiProfiler); cat('✓ EasyMultiProfiler version:', as.character(packageVersion('EasyMultiProfiler')), '\n')"

# 检查 Seurat
echo "🧫 检查 Seurat..."
R -e "library(Seurat); cat('✓ Seurat version:', as.character(packageVersion('Seurat')), '\n')"

# 检查 ChIPseeker
echo "🧬 检查 ChIPseeker..."
R -e "library(ChIPseeker); cat('✓ ChIPseeker loaded\n')"

# 激活 Python 虚拟环境
source /app/web/backend/venv/bin/activate

echo ""
echo "🚀 启动 Flask 服务..."
echo "   访问: http://localhost:5000"
echo ""

# 执行传入的命令
exec "$@"
