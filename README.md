# UI Labels Zh

给已有简体中文界面补译少数仍显示英文的控件。首组规则根据 Notion 桌面版 7.43.0 的界面编写。

| 原标签 | 简体中文 |
|---|---|
| Recents | 最近访问 |
| Favorites | 最爱 |
| Shared | 共享 |
| Private | 私人 |
| Add a property | 添加属性 |

脚本在本地匹配控件和词条，更新显示文字及辅助功能标签。样例也覆盖动态新增控件、用户输入区域和非目标页面。

## 在 macOS 上验证

使用已安装的 Xcode 命令行工具，从仓库根目录运行下列命令。

```sh
demo_dir="$(mktemp -d)"
xcrun swiftc verify.swift -o "$demo_dir/verify"
"$demo_dir/verify" ./ui-labels-zh.user.js
```

三条 `PASS` 分别对应模拟库页、模拟项目页和其他域名。样例使用本地生成的页面和非持久化会话。

## 桌面适配状态

桌面试验版已在开发机启动到中文登录页。登录后的工作区补译和重启后的效果仍待验证。

## 许可证

本仓库的补译脚本、测试和文档采用 [MIT 许可证](LICENSE)。

Notion 是 Notion Labs, Inc. 的商标。UI Labels Zh 是独立项目。
