# Qizip v0.2 手动验收清单

## Milestone 1：内置 7zz

目标：QiZip 优先使用 app bundle 内的官方 `7zz`，不再强依赖用户安装 Homebrew sevenzip。

查找顺序：

1. `Qizip.app/Contents/Resources/7zz`
2. `/opt/homebrew/bin/7zz`
3. `/usr/local/bin/7zz`
4. `/usr/bin/7zz`
5. 开发调试用 `QIZIP_SEVENZIP_PATH`
6. Debug 构建下的 `.build/tools/7zip/7zz`

如果使用外部开发路径，可以设置：

```bash
export QIZIP_SEVENZIP_PATH=/Users/cloud/code/CodeRepository/xcode_programmes/Qizip/Qizip/.build/tools/7zip/7zz
```

## 准备

1. 用 Xcode 构建并运行 Qizip。
2. 准备普通路径、带空格路径、中文路径下的压缩包和待压缩文件。
3. 准备一个只有单个顶层文件夹的压缩包。
4. 准备一个包含多个顶层文件或文件夹的压缩包。
5. 检查构建产物中是否存在 `Qizip.app/Contents/Resources/7zz`，且有执行权限。

## 验收项

- 启动：首页显示“拖入压缩包即可打开，拖入文件即可压缩。”
- 7zz 检测：能显示来源 `Bundled 7zz`、`Homebrew 7zz`、`System 7zz` 或 `Not Found`。
- 7zz 路径：能显示当前使用的 `7zz` 路径。
- 7zz 缺失：显示 `7zz was not found. Please install it with: brew install sevenzip, or bundle 7zz inside QiZip.`
- 7zz 不可执行：bundle 中存在但没有执行权限时显示 `exists but is not executable` 诊断。
- 打开：`打开压缩包` 支持 `7z`、`zip`、`rar`、`tar`、`gz`、`bz2`、`xz`、`zst`、`iso`、`dmg`、`cab`、`wim`。
- 拖拽：拖入单个支持的压缩包后能打开。
- 浏览：表格展示名称、路径、大小、修改时间、是否文件夹。
- 添加：`添加` 显示“添加功能将在下一个版本实现”。
- 解压：`解压` 选择目标文件夹后能成功执行。
- 智能解压单顶层：只有一个顶层项目时直接解压到所选文件夹。
- 智能解压多顶层：多个顶层项目时创建同名文件夹后再解压。
- 智能解压冲突：目标同名文件夹已存在时，自动生成 `名称 2`、`名称 3`。
- Finder：成功解压或压缩后可以点击“在 Finder 中显示”。
- 测试：有效压缩包显示测试通过；损坏压缩包显示测试失败。
- 信息：信息面板显示路径、文件数、总大小、解析状态。
- 压缩 7z：`压缩文件...` 选择文件/文件夹后能保存 `.7z`。
- 压缩 zip：输出扩展名为 `.zip` 时创建 zip 压缩包。
- 默认压缩：保存面板默认使用 `.zip`，默认文件名来自第一个选中项。
- 压缩安全：不要允许把输出压缩包保存到正在压缩的源文件夹内部，例如 `test2zip/test2zip.zip` 或 `test2zip/压缩包.zip`。
- 压缩覆盖：如果用户确认保存到已有压缩包路径，应替换旧压缩包，不能把旧条目残留在新压缩包里。
- 解压覆盖：重复解压到已有同名文件的位置时，不能等待 7zz 交互确认导致 UI 卡住。
- 日志：所有 7zz stdout/stderr 都显示在日志区域。
- 路径安全：中文、空格、引号路径正常工作，因为 Qizip 使用 `Process.executableURL` 和 `Process.arguments`。

## 当前已验证

- Xcode macOS 构建通过。
- Parser/Smart Extract harness 通过。
- v1 archive workflow harness 使用 `test2zip` 通过压缩、列表、测试、智能解压规划和解压验证。
- 项目内 7zz 26.01 arm64 可执行。
- 命令级 `a`、`l -slt`、`t`、`x` 已用中文和空格路径验证通过。

## v0.2 Milestone 1 命令行验证

```bash
swiftc -module-cache-path .build/ModuleCache Qizip/Services/SevenZipLocator.swift Tests/SevenZipLocatorHarness.swift -o .build/sevenzip-locator-harness-bin
.build/sevenzip-locator-harness-bin

swiftc -module-cache-path .build/ModuleCache Qizip/Models/ArchiveEntry.swift Qizip/Models/CompressionOptions.swift Qizip/Services/ArchiveListParser.swift Qizip/Services/ArchiveService.swift Qizip/Services/SevenZipLocator.swift Qizip/Services/SevenZipRunner.swift Qizip/Services/SmartExtractionPlanner.swift Tests/V1ArchiveWorkflowHarness.swift -o .build/v1-archive-workflow-harness
.build/v1-archive-workflow-harness

swiftc -module-cache-path .build/ModuleCache Qizip/Models/ArchiveEntry.swift Qizip/Models/CompressionOptions.swift Qizip/Services/ArchiveListParser.swift Qizip/Services/ArchiveService.swift Qizip/Services/SevenZipLocator.swift Qizip/Services/SevenZipRunner.swift Qizip/Utilities/CompressionDefaults.swift Tests/CompressionSafetyHarness.swift -o .build/compression-safety-harness-bin
.build/compression-safety-harness-bin
```
