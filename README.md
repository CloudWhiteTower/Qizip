# Qizip

Qizip 是一个 macOS 原生 SwiftUI 压缩包管理器，目标是复刻 NanaZip 的核心使用体验，而不是移植 NanaZip 的 Windows 代码。

v1 MVP 聚焦这些能力：

- 打开或拖入压缩包。
- 以文件管理器风格浏览压缩包内容。
- 解压到用户选择的文件夹。
- 智能解压，避免多个顶层文件直接散落到目标目录。
- 测试压缩包完整性。
- 查看压缩包信息。
- 将用户选择的文件或文件夹压缩为 `.7z` 或 `.zip`。
- 在界面中显示 7zz 的 stdout/stderr 日志。

## 运行依赖

Qizip v1 依赖本机 7-Zip 命令行工具 `7zz`。

查找顺序：

1. `/opt/homebrew/bin/7zz`
2. `/usr/local/bin/7zz`

如果两个路径都不存在，App 会显示：

```text
未找到 7zz。请使用 brew install sevenzip 安装。
```

推荐安装方式：

```bash
brew install sevenzip
```

本地开发时，也可以指定项目内下载的 `7zz`：

```bash
export QIZIP_SEVENZIP_PATH=/Users/cloud/code/CodeRepository/xcode_programmes/Qizip/Qizip/.build/tools/7zip/7zz
```

Debug 构建还会尝试读取仓库根目录下的 `.build/tools/7zip/7zz`，便于本地命令行测试。

## 构建

用 Xcode 打开 `Qizip.xcodeproj`，选择 `Qizip` scheme，在 macOS 上运行。

命令行构建：

```bash
xcodebuild -project Qizip.xcodeproj -scheme Qizip -destination 'platform=macOS' -derivedDataPath .build/DerivedData CODE_SIGNING_ALLOWED=NO build
```

## 轻量测试

Parser 和 Smart Extract 规划器可以用 harness 验证：

```bash
swiftc -module-cache-path .build/ModuleCache Qizip/Models/ArchiveEntry.swift Qizip/Services/ArchiveListParser.swift Qizip/Services/SmartExtractionPlanner.swift Tests/ParserPlannerHarness.swift -o .build/parser-planner-harness
.build/parser-planner-harness
```

完整 v1 压缩/列表/测试/智能解压规划/解压流程可以用 harness 验证：

```bash
swiftc -module-cache-path .build/ModuleCache Qizip/Models/ArchiveEntry.swift Qizip/Models/CompressionOptions.swift Qizip/Services/ArchiveListParser.swift Qizip/Services/ArchiveService.swift Qizip/Services/SevenZipLocator.swift Qizip/Services/SevenZipRunner.swift Qizip/Services/SmartExtractionPlanner.swift Tests/V1ArchiveWorkflowHarness.swift -o .build/v1-archive-workflow-harness
.build/v1-archive-workflow-harness
```

如果仓库根目录存在 `test2zip/`，该 harness 会优先压缩并解压这个文件夹；否则会在 `.build/` 下生成等价测试夹。

## v1 不做的范围

- Finder 右键菜单。
- Finder Sync。
- App Store 发布。
- 内嵌 7-Zip core。
- Full Disk Access。
- 持久化 security-scoped bookmarks。

## v1 分发说明

v1 直接依赖本机 Homebrew `7zz`。为了允许 App 调用 `/opt/homebrew/bin/7zz` 或 `/usr/local/bin/7zz`，当前 Xcode target 关闭了 App Sandbox。v1 不走 App Store 分发；文件访问仍通过用户拖拽、`NSOpenPanel` 和 `NSSavePanel` 发起。
