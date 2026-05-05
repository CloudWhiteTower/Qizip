# Qizip

Qizip 是一个 macOS 原生 SwiftUI 压缩包管理器，目标是复刻 NanaZip 的核心使用体验，而不是移植 NanaZip 的 Windows 代码。

v0.1 MVP 已完成这些能力：

- 打开或拖入压缩包。
- 以文件管理器风格浏览压缩包内容。
- 解压到用户选择的文件夹。
- 智能解压，避免多个顶层文件直接散落到目标目录。
- 测试压缩包完整性。
- 查看压缩包信息。
- 将用户选择的文件或文件夹压缩为 `.7z` 或 `.zip`。
- 在界面中显示 7zz 的 stdout/stderr 日志。

## v0.2 目标

v0.2 的方向是从“能用的 7zz GUI wrapper”升级为更接近 macOS 系统体验的压缩包管理器。第一轮已经从 **Milestone 1：内置 7zz** 开始推进。

v0.2 计划按以下顺序实现：

1. 内置 7zz + SevenZipLocator。
2. 文件关联 + AppLaunchRouter。
3. Archive Browser 升级。
4. Smart Extract 升级。
5. QuickOperationPanel。
6. JobQueueManager。
7. Preferences + BookmarkManager。
8. Finder Quick Actions。
9. Legal / About / README。

## 7zz 查找顺序

QiZip v0.2 开始优先使用 app bundle 内置的官方 `7zz`，用户下载后不应再强依赖 Homebrew。

查找顺序：

1. `Qizip.app/Contents/Resources/7zz`
2. `/opt/homebrew/bin/7zz`
3. `/usr/local/bin/7zz`
4. `/usr/bin/7zz`
5. 开发调试用 `QIZIP_SEVENZIP_PATH`
6. Debug 构建下的 `.build/tools/7zip/7zz`

如果所有路径都不可用，App 会显示：

```text
7zz was not found. Please install it with: brew install sevenzip, or bundle 7zz inside QiZip.
```

如果 bundle 内的 `7zz` 存在但不可执行，App 会显示“exists but is not executable”诊断。开发时可执行：

```bash
chmod +x Qizip/Vendor/7zz
```

本地开发时，也可以指定外部 `7zz`：

```bash
export QIZIP_SEVENZIP_PATH=/Users/cloud/code/CodeRepository/xcode_programmes/Qizip/Qizip/.build/tools/7zip/7zz
```

UI 会显示当前来源：`Bundled 7zz`、`Homebrew 7zz`、`System 7zz` 或 `Not Found`。

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

SevenZipLocator 的 bundle-first 行为可以用 harness 验证：

```bash
swiftc -module-cache-path .build/ModuleCache Qizip/Services/SevenZipLocator.swift Tests/SevenZipLocatorHarness.swift -o .build/sevenzip-locator-harness-bin
.build/sevenzip-locator-harness-bin
```

## v0.2 暂不做的范围

- App Store 发布。
- 内嵌 7-Zip core。
- Full Disk Access。
- 重写 7-Zip 压缩算法。
- 主动扫描 Downloads、Desktop、Documents。
- 复制 NanaZip 的名称、图标和品牌资产。

## 分发与权限说明

当前 target 仍关闭 App Sandbox，适用于直接分发和本地验证。v0.2 Milestone 1 改为优先调用 app bundle 内的 `7zz`，但文件访问仍通过用户拖拽、`NSOpenPanel` 和 `NSSavePanel` 发起。后续 v0.2 会单独加入 Preferences、BookmarkManager 和 Finder Quick Actions。

## 第三方说明

QiZip 使用 7-Zip / `7zz` 执行压缩包操作。许可证文件位于 `Qizip/Legal/7-Zip-LICENSE.txt`，第三方说明位于 `Qizip/Legal/ThirdPartyNotices.md`。

QiZip is inspired by NanaZip and powered by 7-Zip. QiZip 不是 NanaZip for macOS，也不是 NanaZip 官方 Mac 版本。
