# Qizip v1 手动验收清单

在装有 `7zz` 的 Mac 上执行。支持路径：

- `/opt/homebrew/bin/7zz`
- `/usr/local/bin/7zz`

如果使用项目内下载的 `7zz`，先设置：

```bash
export QIZIP_SEVENZIP_PATH=/Users/cloud/code/CodeRepository/xcode_programmes/Qizip/Qizip/.build/tools/7zip/7zz
```

## 准备

1. 用 Xcode 构建并运行 Qizip。
2. 准备普通路径、带空格路径、中文路径下的压缩包和待压缩文件。
3. 准备一个只有单个顶层文件夹的压缩包。
4. 准备一个包含多个顶层文件或文件夹的压缩包。

## 验收项

- 启动：首页显示“拖入压缩包即可打开，拖入文件即可压缩。”
- 7zz 检测：能显示检测到的 `7zz` 路径；缺失时显示清晰中文提示。
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
- 日志：所有 7zz stdout/stderr 都显示在日志区域。
- 路径安全：中文、空格、引号路径正常工作，因为 Qizip 使用 `Process.executableURL` 和 `Process.arguments`。

## 当前已验证

- Xcode macOS 构建通过。
- Parser/Smart Extract harness 通过。
- v1 archive workflow harness 使用 `test2zip` 通过压缩、列表、测试、智能解压规划和解压验证。
- 项目内 7zz 26.01 arm64 可执行。
- 命令级 `a`、`l -slt`、`t`、`x` 已用中文和空格路径验证通过。
