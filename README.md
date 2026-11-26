# AI Usage Menubar

[中文](#chinese) · [English](#english)

<a name="chinese"></a>
## 中文

在 macOS 菜单栏并排显示四项：

**GPT/Codex 剩余额度 → GPT 五小时窗口倒计时 → DeepSeek API 余额 → DeepSeek 峰谷切换**

额度和余额由 [CodexBar](https://github.com/steipete/CodexBar) 获取。本仓库提供独立的 GPT 倒计时应用、[SwiftBar](https://github.com/swiftbar/SwiftBar) 的 DeepSeek 峰谷插件，以及整套安装配置说明。两个计时器在本机运行，计时本身不发网络请求。

## 安装

1. 安装 CodexBar 和 SwiftBar。用 CodexBar 自己的设置打开 **Codex** 和 **DeepSeek**，完成 Codex 登录，并在 DeepSeek 提供商设置里加入自己的 API 密钥。菜单栏使用分开的提供商图标。Codex 选会话或周剩余百分比，DeepSeek 选余额。详见 [菜单栏布局](https://github.com/steipete/CodexBar/blob/main/docs/ui.md) 和 [DeepSeek 提供商](https://github.com/steipete/CodexBar/blob/main/docs/deepseek.md)。
2. 下载或克隆本仓库，在仓库目录运行 `./build.sh`。需要 Xcode 命令行工具（可用 `xcode-select --install` 安装）。把生成的 `build/GPT Quota Countdown.app` 移到「应用程序」并打开。需要开机启动，可将它加入 macOS 的登录项。
3. 把 `deepseek/deepseek-pricing.1m.sh` 放进 SwiftBar 的插件文件夹，保留可执行权限，刷新 SwiftBar。红色双硬币表示峰时，绿色单硬币表示闲时。默认显示**本地时区的下次切换时刻**，只在峰谷边界重绘。要显示随时间变化的倒计时，把脚本顶部 `display=${DEEPSEEK_SWITCH_FORMAT:-time}` 的默认值从 `time` 改为 `countdown`，再刷新插件。
4. 按住 Command 拖动菜单栏图标，按上面的顺序排列。

## 数据与计时

- GPT 倒计时读取当前 macOS 用户的 CodexBar 本地快照中第一条记录的五小时窗口重置时间。缺少兼容数据时显示 `—`。如果使用多个 Codex 账号，并希望倒计时始终跟随当前选中的账号，可在支持的 CodexBar 版本中改用内置的 `Session → Resets in` 菜单栏字段。
- DeepSeek 倒计时针对 **API 峰谷价格切换**。脚本按北京时间和中国节假日计算，再按电脑时区显示。中国节假日表覆盖 2026–2027 年，之后会提示更新日历。[DeepSeek 官方费率](https://api-docs.deepseek.com/zh-cn/quick_start/pricing/) · [2026 年节假日](https://www.beijing.gov.cn/cs/gncs/zcwj/202603/t20260327_4568275.html) · [2027 年节假日](https://www.forestry.gov.cn/lyj/1/szxx/20261105/695102.html)
- 账号、API 密钥和用量历史由 CodexBar 管理。仓库仅包含代码、安装说明和使用合成数据的测试。

在 macOS 上运行 `./tests/check.sh` 可构建并验证重置时间、峰谷边界和节假日逻辑。测试无需账号或密钥。

---

<a name="english"></a>
## English

Displays four items side by side in the macOS menu bar: **GPT/Codex quota remaining → GPT five-hour reset countdown → DeepSeek API balance → DeepSeek peak/off-peak switch**.

[CodexBar](https://github.com/steipete/CodexBar) supplies quota and balance data. This repository provides a standalone GPT countdown app, a DeepSeek pricing-period plugin for [SwiftBar](https://github.com/swiftbar/SwiftBar), and setup instructions. Both timers run locally without making network requests themselves.

### Installation

1. Install CodexBar and SwiftBar. Enable Codex and DeepSeek in CodexBar, sign in to Codex, and enter your own DeepSeek API key in its provider settings. Use separate provider icons, showing the session or weekly percentage for Codex and the balance for DeepSeek. See [menu-bar layout](https://github.com/steipete/CodexBar/blob/main/docs/ui.md) and [DeepSeek setup](https://github.com/steipete/CodexBar/blob/main/docs/deepseek.md).
2. Run `./build.sh` in this repository with the Xcode Command Line Tools installed (`xcode-select --install`). Move `build/GPT Quota Countdown.app` into Applications and open it. Add it to Login Items if you want it to launch automatically.
3. Copy `deepseek/deepseek-pricing.1m.sh` into the SwiftBar plugin folder, keep it executable, and refresh SwiftBar. Two red coins mark peak pricing; one green coin marks off-peak pricing. By default it displays the next switch in your local time zone and redraws at the pricing boundary. To show a live countdown, change the default for `DEEPSEEK_SWITCH_FORMAT` from `time` to `countdown` near the top of the script.
4. Hold Command and drag the menu-bar icons into the order above.

### Data and timing

- GPT reads the first record in the current macOS user's local CodexBar snapshot and shows `—` if compatible data is unavailable. For multiple Codex accounts, a supported CodexBar build can instead use its `Session → Resets in` field to follow the selected account.
- The DeepSeek timer tracks API pricing windows. It computes them in Beijing time with the Chinese holiday calendar, then converts them to the Mac's time zone. The bundled holiday data covers 2026–2027. See [official pricing](https://api-docs.deepseek.com/zh-cn/quick_start/pricing/).
- CodexBar manages accounts, keys, and usage history. This repository ships code, documentation, and synthetic test data only. Run `./tests/check.sh` on macOS to check reset timestamps, pricing boundaries, and holidays without credentials.
