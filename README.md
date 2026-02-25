# EasyMultiProfiler 完整版
# 包含 R 包 + Web 的统一仓库

## 快速开始

### 一键安装（推荐）

```bash
# 下载并运行安装脚本
bash <(curl -s https://raw.githubusercontent.com/xielab2017/EasyMultiProfiler/main/install.sh)
```

### 手动安装

```bash
# 1. 克隆完整仓库
git clone --recursive https://github.com/xielab2017/EasyMultiProfiler.git
cd EasyMultiProfiler

# 2. 运行安装脚本
./install.sh
```

### 启动服务

```bash
cd EasyMultiProfiler
./start.sh
```

访问 http://localhost:3000 使用 Web 界面

---

## 仓库结构

```
EasyMultiProfiler/
├── R-package/          # R包源码 (Git子模块)
│   ├── R/             # R函数代码
│   ├── man/           # 文档
│   └── DESCRIPTION    # 包描述
│
├── web/               # Web版源码 (Git子模块)
│   ├── backend/       # Flask后端
│   ├── frontend/      # React前端
│   └── docs/          # 文档
│
├── install.sh         # 一键安装脚本
├── start.sh           # 启动脚本
├── stop.sh            # 停止脚本
├── update.sh          # 更新脚本
└── README.md          # 本文件
```

---

## 功能模块

| 模块 | R包函数 | Web界面 | 状态 |
|------|---------|---------|------|
| RNA-seq | `EMP_rnaseq_analysis()` | ✅ | 完整 |
| 蛋白质组学 | `EMP_proteomics_analysis()` | ✅ | 完整 |
| 单细胞RNA-seq | `EMP_scrnaseq_analysis()` | ✅ | 完整 |
| 微生物组 | `EMP_microbiome_analysis()` | ✅ | 完整 |
| ChIP-seq | `EMP_chipseq_analysis()` | ✅ | 完整 |
| CUT&Tag | `EMP_cutntag_analysis()` | ✅ | 完整 |
| CUT&RUN | `EMP_cutnrun_analysis()` | ✅ | 完整 |
| 代谢组 | `EMP_metabolome_analysis()` | ✅ | 完整 |
| 多组学整合 | `EMP_multiomics_integration()` | ✅ | 完整 |

---

## R 包使用

```r
library(EasyMultiProfiler)

# 单细胞分析
result <- EMP_scrnaseq_analysis(
    counts = count_matrix,
    metadata = cell_metadata
)

# ChIP-seq分析
result <- EMP_chipseq_analysis(
    peak_file = "peaks.narrowPeak"
)

# 多组学整合
result <- EMP_multiomics_integration(
    data_list = list(
        rnaseq = rna_data,
        chipseq = chip_data
    )
)
```

---

## Web 使用

1. 打开浏览器访问 http://localhost:3000
2. 上传数据文件
3. 选择分析模块
4. 配置参数
5. 等待分析完成
6. 下载结果报告

---

## 系统要求

### 必需
- R >= 4.0.0
- Python >= 3.8
- Git

### 推荐
- Node.js >= 16 (用于前端开发)
- 8GB+ 内存
- 10GB+ 磁盘空间

---

## 文档

- [架构设计](docs/architecture.md)
- [API文档](docs/api.md)
- [安装指南](docs/installation.md)
- [使用教程](docs/tutorial.md)

---

## 引用

Science China Life Sciences (2025), DOI: 10.1007/s11427-025-3035-0

---

## 许可证

MIT License

---

## 联系方式

- 项目主页: https://github.com/xielab2017/EasyMultiProfiler
- 文档: https://easymultiprofiler.xielab.net
- 邮箱: contact@xielab.net
