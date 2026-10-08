# Pale Coins 简体中文汉化 / Simplified Chinese Localization

《Pale Coins》完整简体中文汉化包。界面、物品、任务、全部对话均已翻译，约 4 万字。

A complete Simplified Chinese localization pack for
[Pale Coins](https://store.steampowered.com/app/2438330/Pale_Coins/) (v1.1.4).

> 已获得作者 Lukas Irzl 许可公开发布。
> Released publicly with the permission of the developer, Lukas Irzl.

---

## 关于翻译质量 / About translation quality

本汉化由 **AI 辅助翻译**完成，之后经过：结构校验（占位符、`#args` 参数、CSV 格式、
与原文逐行对齐）、全包术语统一、以及游戏内实机测试。母语者通读观感不错，
但**尚未逐句精校**，可能存在别扭或错译之处。

欢迎提 [Issue](../../issues) 报告问题，或直接提 Pull Request 修改。
报告时请附上**截图**或**具体是哪一句**，这样修起来最快。

*Translated with AI assistance, then structurally validated, terminology-unified and
tested in-game. It has not yet had a full line-by-line editorial review — please report
anything that reads wrong.*

---

## 安装方法 / Installation

先找到游戏目录（Steam 里右键游戏 → 管理 → 浏览本地文件），
默认通常是 `...\steamapps\common\Pale Coins`。

### 方法 A：一键安装（推荐）

下载并解压本包后，**双击 `install.bat`** 即可。
脚本会自动找到游戏目录、备份原字体、复制汉化文件、并把语言设为中文。
如果没有自动找到游戏，会提示你把游戏目录路径贴进去。

卸载：双击 `uninstall.bat`，会还原原版字体、删除汉化文件、把语言改回英文。

> **请用 `.bat` 而不是直接跑 `.ps1`。** Windows 默认禁止执行 PowerShell 脚本
> （执行策略为 Restricted），直接双击或右键 `install.ps1` 多半会报
> "running scripts is disabled on this system"。`.bat` 会自动带上
> `-ExecutionPolicy Bypass` 绕过这个限制，跟系统语言（简中/繁中/英文）无关。

也可以直接指定路径：

```
install.bat -GamePath "D:\Steam\steamapps\common\Pale Coins"
```

> 装之前请先关掉游戏。脚本会把原版字体备份到游戏目录下的 `_zh_backup\`。

### 方法 A（手动版）：不想跑脚本的话

1. **备份**游戏目录下的 `PixelFont.ttf` 和 `pixelplay.ttf`（复制一份到别处即可）。
2. 把本包的 `lang\localization\zh` 整个文件夹，复制到游戏的 `lang\localization\` 下。
   最终路径应为 `Pale Coins\lang\localization\zh\Language.csv`。
3. 把 `fonts\fusion-pixel-12px-proportional-zh_hans.ttf` 复制两份到游戏根目录，
   分别**改名覆盖** `PixelFont.ttf` 和 `pixelplay.ttf`。
   （`Strong-Regular.ttf` 保持原样，不要动。）
4. 打开 `%LOCALAPPDATA%\Pale_Coins\settings.json`，
   把 `"gameplay_language":"en"` 改成 `"gameplay_language":"zh"`，保存。
5. 启动游戏。

#### ⚠️ 方法 A 的两个已知问题

- **不要在「游戏设置」里点「保存设置」**。因为原版游戏的语言列表里没有中文，
  语言那一栏会显示成 English，一旦保存就会把语言重置回英文。
  真的点了也不要紧，重做第 4 步即可。
- 屏幕**最底部**的操作提示文字（比如物品栏下方那一行）会被屏幕边缘裁掉一点。
  只是显示问题，不影响游玩。

上面两个问题都可以用方法 B 彻底解决。

### 方法 B：修改 data.win（进阶，体验完整）

需要 [UndertaleModTool](https://github.com/UnderminersTeam/UndertaleModTool)。
这个方法会把「中文」正式加进游戏的语言选项里，两个已知问题都不会出现。

1. 完成方法 A 的第 1、2 步。
2. 把 `fonts\fusion-pixel-12px-proportional-zh_hans.ttf` 改名覆盖游戏根目录的
   **`Strong-Regular.ttf`**（这个方法下 `PixelFont.ttf` 和 `pixelplay.ttf` 保持原样）。
3. 用 UndertaleModTool 打开游戏的 `data.win`，运行 `tools\add_zh_language.csx`，
   保存。命令行方式：
   ```
   UndertaleModCli.exe load "data.win" -s "add_zh_language.csx" -o "data_new.win"
   ```
   然后用 `data_new.win` 替换原来的 `data.win`（记得先备份）。
4. 启动游戏 → 游戏设置 → 游戏性 → 语言 → 中文。

> `data.win` 是游戏本体文件，本仓库**不会**提供修改好的版本，
> 请在自己的游戏副本上操作。

### 更新游戏后 / After a game update

Steam 更新或「验证文件完整性」会还原被替换的字体和 `data.win`，
但不会删除 `lang\localization\zh` 文件夹。重做字体那一步（方法 B 再重新打一次补丁）即可。

---

## 字体 / Font

[Fusion Pixel Font 缝合像素字体](https://github.com/TakWolf/fusion-pixel-font)
by TakWolf，采用 **SIL Open Font License 1.1**（见 `fonts/OFL.txt`）。
12px 像素字体，与游戏原本的像素风格相符。

---

## 参与改进 / Contributing

翻译文件都是纯 CSV，用文本编辑器就能改，但**格式有严格要求**，
改之前请先看 [CONTRIBUTING.md](CONTRIBUTING.md)。
术语请对照 [GLOSSARY.md](GLOSSARY.md) 保持一致。

`tools\validate.ps1` 可以在提交前自检格式是否被改坏。

---

## 授权 / Licensing

- **译文**：自由使用，无需署名。
- **游戏原文**：CSV 中的英文、德文原文版权归作者 Lukas Irzl 所有，
  本仓库经作者许可发布，仅用于本地化用途。
- **字体**：SIL OFL 1.1，详见 `fonts/OFL.txt`。

详见 [NOTICE.md](NOTICE.md)。
