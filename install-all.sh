# EasyMultiProfiler 统一安装器
# 一键安装 R 包 + Web 环境

#!/bin/bash
# install.sh - EasyMultiProfiler 完整安装脚本
# 同时安装 R 包和 Web 环境

set -e  # 遇到错误立即退出

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║          EasyMultiProfiler 完整安装程序                       ║"
echo "║          R包 + Web版 一键安装                                 ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 安装路径
INSTALL_DIR="${HOME}/EasyMultiProfiler"
R_LIB_DIR="${INSTALL_DIR}/R-library"
WEB_DIR="${INSTALL_DIR}/web"
CONDA_ENV="easymulti"

# 检查命令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 打印进度
print_step() {
    echo ""
    echo -e "${BLUE}▶ $1${NC}"
    echo "────────────────────────────────────────────────────────────────"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# ============ 系统检查 ============
print_step "步骤 1/6: 系统环境检查"

# 检查操作系统
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
    print_success "检测到 Linux 系统"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
    print_success "检测到 macOS 系统"
else
    print_error "不支持的操作系统: $OSTYPE"
    exit 1
fi

# 检查必要依赖
dependencies=("R" "python3" "git")
missing_deps=()

for dep in "${dependencies[@]}"; do
    if command_exists "$dep"; then
        print_success "$dep 已安装"
    else
        missing_deps+=("$dep")
        print_error "$dep 未安装"
    fi
done

if [ ${#missing_deps[@]} -gt 0 ]; then
    echo ""
    print_warning "请先安装以下依赖："
    for dep in "${missing_deps[@]}"; do
        echo "  - $dep"
    done
    echo ""
    echo "安装命令："
    if [ "$OS" == "macos" ]; then
        echo "  brew install r python3 git"
    else
        echo "  sudo apt-get install r-base python3 python3-pip git  # Ubuntu/Debian"
        echo "  sudo yum install R python3 python3-pip git           # CentOS/RHEL"
    fi
    exit 1
fi

# 检查 Node.js (可选，用于Web开发)
if command_exists "node"; then
    print_success "Node.js 已安装"
    NODE_INSTALLED=true
else
    print_warning "Node.js 未安装，Web开发模式将不可用"
    NODE_INSTALLED=false
fi

# ============ 创建安装目录 ============
print_step "步骤 2/6: 创建安装目录"

mkdir -p "$INSTALL_DIR"
mkdir -p "$R_LIB_DIR"
mkdir -p "$WEB_DIR"
mkdir -p "${INSTALL_DIR}/data"
mkdir -p "${INSTALL_DIR}/logs"

print_success "安装目录: $INSTALL_DIR"

# ============ 安装 R 包 ============
print_step "步骤 3/6: 安装 EasyMultiProfiler R 包"

cd "$INSTALL_DIR"

# 克隆或更新 R 包仓库
if [ -d "EasyMultiProfiler-R/.git" ]; then
    print_warning "R 包仓库已存在，更新中..."
    cd EasyMultiProfiler-R
    git pull origin v2.0-update
    cd ..
else
    print_success "克隆 R 包仓库..."
    git clone -b v2.0-update https://github.com/xielab2017/EasyMultiProfiler.git EasyMultiProfiler-R
fi

# 安装 R 包
print_success "安装 R 包及其依赖（这可能需要几分钟）..."

R CMD INSTALL --library="$R_LIB_DIR" EasyMultiProfiler-R 2>&1 | tee "${INSTALL_DIR}/logs/r_install.log"

if [ $? -eq 0 ]; then
    print_success "R 包安装成功"
else
    print_error "R 包安装失败，查看日志: ${INSTALL_DIR}/logs/r_install.log"
    exit 1
fi

# ============ 安装 Web 环境 ============
print_step "步骤 4/6: 安装 Web 环境"

# 克隆或更新 Web 仓库
if [ -d "EasyMultiProfiler-Web/.git" ]; then
    print_warning "Web 仓库已存在，更新中..."
    cd EasyMultiProfiler-Web
    git pull origin main
    cd ..
else
    print_success "克隆 Web 仓库..."
    git clone https://github.com/xielab2017/EasyMultiProfiler-V2.git EasyMultiProfiler-Web
fi

# 创建 Python 虚拟环境（推荐）
print_success "创建 Python 虚拟环境..."
cd EasyMultiProfiler-Web/backend

if command_exists "python3-venv" || python3 -m venv --help >/dev/null 2>&1; then
    python3 -m venv venv
    source venv/bin/activate
    
    # 安装 Python 依赖
    print_success "安装 Python 依赖..."
    pip install --upgrade pip
    pip install -r requirements.txt 2>&1 | tee "${INSTALL_DIR}/logs/pip_install.log"
    
    print_success "Python 环境配置完成"
else
    print_warning "无法创建虚拟环境，将使用系统 Python"
    pip3 install -r requirements.txt 2>&1 | tee "${INSTALL_DIR}/logs/pip_install.log"
fi

cd "$INSTALL_DIR"

# ============ 安装前端依赖 ============
if [ "$NODE_INSTALLED" = true ]; then
    print_step "步骤 5/6: 安装前端依赖"
    
    cd EasyMultiProfiler-Web/frontend
    
    if command_exists "npm"; then
        print_success "安装 npm 依赖..."
        npm install 2>&1 | tee "${INSTALL_DIR}/logs/npm_install.log"
        print_success "前端依赖安装完成"
    else
        print_warning "npm 不可用，跳过前端安装"
    fi
    
    cd "$INSTALL_DIR"
else
    print_step "步骤 5/6: 跳过前端安装 (Node.js 未安装)"
fi

# ============ 创建启动脚本 ============
print_step "步骤 6/6: 创建启动脚本"

# 创建统一的启动脚本
cat > "${INSTALL_DIR}/start.sh" << 'EOF'
#!/bin/bash
# EasyMultiProfiler 启动脚本

INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WEB_DIR="${INSTALL_DIR}/EasyMultiProfiler-Web"
R_LIB_DIR="${INSTALL_DIR}/R-library"

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║          EasyMultiProfiler 启动程序                           ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# 启动后端
echo "🚀 启动后端服务..."
cd "${WEB_DIR}/backend"

# 激活虚拟环境
if [ -f "venv/bin/activate" ]; then
    source venv/bin/activate
fi

# 设置 R 库路径
export R_LIBS="${R_LIB_DIR}:${R_LIBS}"

# 启动 Flask
python app.py &
BACKEND_PID=$!
echo "   后端 PID: $BACKEND_PID"

# 启动前端（如果Node可用）
if command -v npm >/dev/null 2>&1 && [ -f "${WEB_DIR}/frontend/package.json" ]; then
    echo ""
    echo "🌐 启动前端服务..."
    cd "${WEB_DIR}/frontend"
    npm start &
    FRONTEND_PID=$!
    echo "   前端 PID: $FRONTEND_PID"
fi

echo ""
echo "────────────────────────────────────────────────────────────────"
echo "✅ 服务已启动！"
echo ""
echo "📱 访问地址:"
echo "   Web界面: http://localhost:3000"
echo "   API地址: http://localhost:5000"
echo ""
echo "🛑 停止服务:"
echo "   kill $BACKEND_PID"
[ ! -z "$FRONTEND_PID" ] && echo "   kill $FRONTEND_PID"
echo ""
echo "日志文件: ${INSTALL_DIR}/logs/"
echo "────────────────────────────────────────────────────────────────"

# 保存PID
echo $BACKEND_PID > "${INSTALL_DIR}/backend.pid"
[ ! -z "$FRONTEND_PID" ] && echo $FRONTEND_PID > "${INSTALL_DIR}/frontend.pid"

wait
EOF

chmod +x "${INSTALL_DIR}/start.sh"

# 创建停止脚本
cat > "${INSTALL_DIR}/stop.sh" << 'EOF'
#!/bin/bash
INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -f "${INSTALL_DIR}/backend.pid" ]; then
    kill $(cat "${INSTALL_DIR}/backend.pid") 2>/dev/null
    rm "${INSTALL_DIR}/backend.pid"
    echo "✓ 后端服务已停止"
fi

if [ -f "${INSTALL_DIR}/frontend.pid" ]; then
    kill $(cat "${INSTALL_DIR}/frontend.pid") 2>/dev/null
    rm "${INSTALL_DIR}/frontend.pid"
    echo "✓ 前端服务已停止"
fi
EOF

chmod +x "${INSTALL_DIR}/stop.sh"

# 创建更新脚本
cat > "${INSTALL_DIR}/update.sh" << 'EOF'
#!/bin/bash
INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🔄 更新 EasyMultiProfiler..."

# 更新 R 包
echo "更新 R 包..."
cd "${INSTALL_DIR}/EasyMultiProfiler-R"
git pull origin v2.0-update
R CMD INSTALL --library="${INSTALL_DIR}/R-library" . 2>&1 | tee "${INSTALL_DIR}/logs/r_update.log"

# 更新 Web
echo "更新 Web..."
cd "${INSTALL_DIR}/EasyMultiProfiler-Web"
git pull origin main

# 更新 Python 依赖
cd backend
if [ -f "venv/bin/activate" ]; then
    source venv/bin/activate
fi
pip install -r requirements.txt --upgrade

echo "✅ 更新完成！"
EOF

chmod +x "${INSTALL_DIR}/update.sh"

print_success "启动脚本创建完成"

# ============ 完成 ============
echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║          🎉 安装完成！                                        ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "📂 安装目录: $INSTALL_DIR"
echo ""
echo "🚀 快速开始:"
echo "   cd $INSTALL_DIR"
echo "   ./start.sh"
echo ""
echo "📖 常用命令:"
echo "   ./start.sh   - 启动服务"
echo "   ./stop.sh    - 停止服务"
echo "   ./update.sh  - 更新到最新版"
echo ""
echo "🌐 访问地址:"
echo "   Web界面: http://localhost:3000"
echo "   API地址: http://localhost:5000"
echo ""
echo "📚 日志文件: ${INSTALL_DIR}/logs/"
echo ""
echo "💡 提示:"
echo "   - R包安装在: $R_LIB_DIR"
echo "   - Web代码在: $WEB_DIR"
echo "   - 数据存储在: ${INSTALL_DIR}/data/"
echo ""
echo "═════════════════════════════════════════════════════════════════"
