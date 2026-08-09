# 授权说明 / Licensing Notice

本仓库包含三类内容，授权情况各不相同。
This repository contains three kinds of content under different terms.

---

## 1. 中文译文 / The Chinese translation

自由使用、修改、再分发，无需署名。
Free to use, modify and redistribute. No attribution required.

## 2. 游戏原文 / The original game text

汉化文件采用 `key,en,de,zh` 和 `type,id,text,zh` 的列结构 —— 这是游戏本身的格式，
其中的**英文与德文原文版权归游戏作者 Lukas Irzl 所有**。

保留这些列是技术上的必需：游戏依靠它们匹配文本条目。

作者已明确许可本汉化包公开发布：

> "I can't review the localization myself and put it on a beta branch, but you're
> fully welcome to release it publicly (like Nexusmods, etc.). This pack definitely
> would be great for players who prefer Chinese."
> — Lukas Irzl

这些原文仅可用于本地化用途，不得用于其他目的。

*The `en` / `de` / `text` columns contain the original game script, © Lukas Irzl.
They are retained because the game requires them to match entries. Redistribution
here is by the developer's explicit permission, for localization purposes only.*

## 3. 字体 / The font

`fonts/fusion-pixel-12px-proportional-zh_hans.ttf` —
[Fusion Pixel Font](https://github.com/TakWolf/fusion-pixel-font) © TakWolf,
licensed under the **SIL Open Font License 1.1**. 完整许可见 `fonts/OFL.txt`。

OFL 允许随商业软件一同分发（含随游戏打包），但不得单独出售字体本身。

---

## 本仓库不包含 / Not included here

游戏本体文件（`data.win`、`Pale Coins.exe`、音频包等）**不在本仓库内，也不会被提供**。
方法 B 的补丁脚本是在使用者**自己的游戏副本**上运行的。

*No game binaries are distributed. The Method B patch script operates on the user's
own copy of the game.*
