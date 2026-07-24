# 2026-07-24 · 全局动效 · UI 精修 · 触觉反馈

## 目标
以「信号流程优先」为范围，为核心创作链路加入有品味、可感知的动画与合理触觉反馈，统一按钮按压手感，修复少量「死 UI」（修复不删除）。所有动效遵循 `accessibilityReduceMotion`；触觉独立于动效，交由系统全局开关控制。

## 新增
- `Haptics.swift`
  - `enum Haptics`：命令式封装 `impact(.light/.medium/.rigid/.soft)`、`selection()`、`success()`、`warning()`、`error()`（`@MainActor`，惰性 + `prepare()`）。
  - `extension Animation`：暴露 `standardSpring / snappySpring / gentle / pulse` 四个 token，使 `.maybe(.snappySpring, …)` 的前导点语法可解析。
  - `enum ShengbianMotion`：引用上述 token，并提供 `maybe(_:_:)` 便捷 gate（Reduce Motion 时返回 `nil`）。

## 编辑
- `Components.swift`：`ShengbianPressStyle` 公开；新增 `View.shengbianPressable(reduceMotion:)`，把统一按压缩放/透明反馈暴露给自定义按钮。
- `InspirationRecordView.swift`（signature 屏）：录制环呼吸脉动（`pulse`，Reduce Motion 退化为静态）；mic/stop 符号 `.contentTransition(.symbolEffect(.replace))`；各 phase section `.transition` 过渡；触觉：开始 `impact(.medium)`、停止 `impact(.rigid)`、提交 `selection()`、生成完成 `success()`。
- `ProjectDetailView.swift`：`advanceStage` 用 `standardSpring` 包裹推进并附 `success()`；到 `.settled` 追加 `impact(.rigid)`；stageMarker 符号 `.symbolEffect(.bounce)` + replace 过渡；整理 `isCapturing` 声明位置。
- `ProjectPawnWorkspaceView.swift`：消息气泡插入 `.move(edge:.bottom)+.opacity` 过渡 + `gentle`；发送 `impact(.light)`、生成完成 `success()`、停止 `impact(.rigid)`（守卫仅在生成中）、附件导入成功 `selection()` / 失败 `error()`。
- `CreatorMainView.swift` / `ClientMainView.swift`：`.sensoryFeedback(.selection, trigger: selectedTab)`。
- 列表增删动画（`snappySpring`，Reduce Motion gate）：`CreatorHomeView` 近期灵感、`CreatorProjectsView`、`ClientBriefsView`、`ClientHomeView`。
- 按钮统一：`ClientHomeView` 发布按钮、`CreatorProjectsView`/`ClientBriefsView` 空态按钮改为 `ShengbianPrimaryButton`；`InspirationDetailView` 导出/指派/更换按钮套 `shengbianPressable` + 相应触觉。
- 选择态：`AssignInspirationView` 行选中 `symbolEffect(.bounce)`+`selection()`，确认 `success()`，确认栏高度 46→`minimumControlHeight`；`LoginView` 角色选择 `selection()`+bounce，提交成功 `success()` / 校验失败 `error()`（含轻微 fade）。
- 死 UI 修复：`CreatorHomeView` 三个空闭包快捷按钮改为 `CreatorTool` 枚举驱动的工具 sheet（不再「可点无反应」）；`ClientMessagesView` 换成 `ContentUnavailableView` 空状态。

## 构建修复（关键）
命令行 `xcodebuild` 原本失败（`_main` 未定义 → 仅链接了 SPM 包对象）。根因：`project.pbxproj` 的 `PBXFileSystemSynchronizedRootGroup.path` 仍指向已不存在的旧目录名 `inspireFlow（升变PAWN）`，而磁盘真实目录为 `inspireFlow（升变）`，导致 App 自身所有 Swift 源都未纳入编译。
- 修正同步根组 `path` → `inspireFlow（升变）`。
- 随后出现 `Multiple commands produce README.md/SKILL.md`：`RingSDK/` 与 `skills/` 内的 18 个文档/脚本文件被当作资源拷贝并重名冲突。已在 target 的 `membershipExceptions` 中逐条排除这 18 个非源码文件（另含 `MVP 2.md`）。

## 验证
- `xcodebuild -scheme inspireFlow -destination 'platform=iOS Simulator,name=iPhone 11' build` → **BUILD SUCCEEDED**。
- Reduce Motion：所有动效经 `ShengbianMotion.maybe` / `reduceMotion` 三元 gate，开启时退化为无动画或纯 `.opacity`；触觉不受影响。
- 剩余 `RingSound/*` 为既有的 Swift 6 actor 隔离警告（非本次改动引入，未处理）。

## 后续建议
- `ContentView.swift` 为 RootView 未引用的孤儿代码，本轮未动，建议后续确认后清理。
- `RingSDK/`、`skills/` 属文档/脚本，长期看更适合移出 Xcode 源同步目录，避免再触发资源重名。
