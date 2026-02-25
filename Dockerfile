# EasyMultiProfiler Docker 部署
# 同时包含 R 包和 Web 的完整容器

FROM rocker/r-ver:4.3.0

# 系统依赖
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    git \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libhdf5-dev \
    libpng-dev \
    libboost-all-dev \
    libgdal-dev \
    libproj-dev \
    libgeos-dev \
    libudunits2-dev \
    libfontconfig1-dev \
    libcairo2-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libtiff5-dev \
    libjpeg-dev \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /app

# ============ 安装 R 包 ============
RUN R -e "install.packages('devtools', repos='https://cloud.r-project.org/')"
RUN R -e "install.packages('BiocManager', repos='https://cloud.r-project.org/')"

# 克隆并安装 EasyMultiProfiler R 包
RUN git clone -b v2.0-update https://github.com/xielab2017/EasyMultiProfiler.git /tmp/easy-multi-profiler-r \
    && cd /tmp/easy-multi-profiler-r \
    && R -e "devtools::install('.', dependencies=TRUE, repos=BiocManager::repositories())"

# 安装额外的单细胞/ChIP-seq依赖
RUN R -e "BiocManager::install(c('Seurat', 'SingleR', 'celldex', 'monocle3'), ask=FALSE)"
RUN R -e "BiocManager::install(c('ChIPseeker', 'ChIPpeakAnno', 'DiffBind', 'rGADEM'), ask=FALSE)"
RUN R -e "BiocManager::install(c('MOFA2', 'mixOmics', 'iClusterPlus'), ask=FALSE)"

# ============ 安装 Web 后端 ============
RUN git clone https://github.com/xielab2017/EasyMultiProfiler-V2.git /app/web

WORKDIR /app/web/backend

# 创建虚拟环境并安装依赖
RUN python3 -m venv venv \
    && . venv/bin/activate \
    && pip install --no-cache-dir -r requirements.txt

# ============ 安装 Web 前端 ============
WORKDIR /app/web/frontend

RUN npm install \
    && npm run build

# 将前端构建文件复制到后端静态目录
RUN mkdir -p /app/web/backend/static \
    && cp -r /app/web/frontend/build/* /app/web/backend/static/ \
    && rm -rf /app/web/frontend/node_modules

# ============ 配置启动 ============
WORKDIR /app/web/backend

# 暴露端口
EXPOSE 5000

# 启动脚本
COPY docker-entrypoint.sh /app/
RUN chmod +x /app/docker-entrypoint.sh

ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD ["python", "app.py"]
