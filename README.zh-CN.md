# MacClarity

**每一寸空间，都看得清。每一次处理，都有把握。**

[英文](README.md) · [日文](README.ja.md) · [中文网站](docs/zh/index.html)

![MacClarity 将磁盘花盘与证据化性能诊断放在一起](docs/assets/hero.svg)

MacClarity 是一款开源、本地优先的 Mac 空间与性能诊断工具。磁盘花盘让占用分布一目了然，系统趋势帮助你找到卡顿的来处；每一条建议都说明依据，每一次处理都由你确认。

## 核心价值

- **空间与卡顿共同诊断：** 同时理解本地分配空间、内存压力、交换空间和性能趋势。
- **结果始终一致：** 命令行工具、原生界面和网页报告读取同一份版本化诊断快照。
- **建议有据可循：** 个性化建议会说明判断依据，也不会替你授权或执行删除。
- **隐私内建：** 确定性诊断离线完成；分享报告会稳定脱敏本地标识。
- **安全操作：** 系统根目录、符号链接、发生变化的目标、过期授权和继承确认都会被拒绝。

![从收集到验证的诊断链路](docs/assets/diagnosis-flow.svg)

## 安装与开始使用

需要 macOS 14+ 和 Swift 6：

```bash
git clone https://github.com/SichenTao/macclarity.git
cd macclarity
./install.sh
```

建议先体验合成演示，不扫描本机，也不包含真实文件：

```bash
swift run macclarity demo --output macclarity-demo.html
open macclarity-demo.html
```

准备好后，运行一次简短的只读诊断：

```bash
swift run macclarity diagnose --path "$HOME" --duration 30 --output report.html
```

报告默认包含本地完整路径。分享前请加入 `--share-redacted`。

## 应该先用哪个功能

1. **磁盘花盘：** 可用空间不足，或者“系统数据”看起来异常庞大时优先使用。
2. **性能趋势：** Mac 变慢、发热、频繁停顿时优先使用。
3. **综合体检：** 暂时分不清是空间还是运行状态导致问题时使用。

当前版本是源码预览版。通过 Apple 签名与公证门禁后，才会提供可直接下载的应用安装包。

## 当前完成度

| 入口 | 用途 | 状态 |
|---|---|---|
| 命令行工具 | 受预算限制的空间与性能采集，生成数据和网页报告 | 可用 |
| 网页报告 | 磁盘花盘、建议顺序和性能趋势 | 可用 |
| 原生应用 | 空间诊断、性能诊断、综合体检 | 预览 |
| 个性化建议 | 证据化解释与只读检查器 | 契约可用 |
| 清理 | 精确清单、限时凭证、移入废纸篓 | 开发者预览 |

运行 `./scripts/verify.sh` 可完成构建、测试、隐私扫描、预算检查和演示渲染。详细边界见 [隐私说明](PRIVACY.md)、[安全策略](SECURITY.md) 与 [威胁模型](THREAT_MODEL.md)。

项目采用 Apache-2.0 许可证，欢迎提交可复现的问题和贡献。
