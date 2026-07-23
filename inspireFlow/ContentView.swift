//
//  ContentView.swift
//  inspireFlow
//
//  Created by 叶文峰 on 2026/7/23.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: AppTab = .inspiration

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                InspirationDemoView()
            }
            .tabItem {
                Label(
                    AppTab.inspiration.title,
                    systemImage: AppTab.inspiration.symbol
                )
            }
            .tag(AppTab.inspiration)

            NavigationStack {
                CreationDemoView()
            }
            .tabItem {
                Label(
                    AppTab.creation.title,
                    systemImage: AppTab.creation.symbol
                )
            }
            .tag(AppTab.creation)

            NavigationStack {
                CollaborationDemoView()
            }
            .tabItem {
                Label(
                    AppTab.collaboration.title,
                    systemImage: AppTab.collaboration.symbol
                )
            }
            .tag(AppTab.collaboration)

            NavigationStack {
                ProfileDemoView()
            }
            .tabItem {
                Label(
                    AppTab.profile.title,
                    systemImage: AppTab.profile.symbol
                )
            }
            .tag(AppTab.profile)
        }
        .tint(.white)
        .preferredColorScheme(.dark)
    }
}

// MARK: - Inspiration

private struct InspirationDemoView: View {
    @State private var isListening = false
    @State private var privacyLevel: PrivacyLevel = .privateOnly

    var body: some View {
        DemoPageBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    PawnStatusCard(isListening: isListening)

                    captureButton

                    privacySection

                    recentIdeasSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("捕捉灵感")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                } label: {
                    Image(systemName: "sparkles")
                        .foregroundStyle(.white)
                }
                .accessibilityLabel("PAWN")
            }
        }
    }

    private var captureButton: some View {
        Button {
            withAnimation(
                .spring(
                    response: 0.32,
                    dampingFraction: 0.84
                )
            ) {
                isListening.toggle()
            }
        } label: {
            HStack(spacing: 14) {
                Image(
                    systemName: isListening
                        ? "stop.fill"
                        : "mic.fill"
                )
                .font(.title3.weight(.bold))
                .frame(width: 48, height: 48)
                .background(
                    isListening
                        ? Color.white.opacity(0.18)
                        : Color.black.opacity(0.08),
                    in: Circle()
                )

                VStack(alignment: .leading, spacing: 3) {
                    Text(
                        isListening
                            ? "结束捕捉"
                            : "开始捕捉"
                    )
                    .font(.headline)

                    Text(
                        isListening
                            ? "PAWN 将保存当前对话"
                            : "说出脑海中刚刚出现的想法"
                    )
                    .font(.caption)
                    .foregroundStyle(
                        isListening
                            ? Color.white.opacity(0.72)
                            : Color.black.opacity(0.62)
                    )
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.bold())
            }
            .foregroundStyle(
                isListening
                    ? Color.white
                    : Color.black
            )
            .padding(14)
            .background {
                RoundedRectangle(
                    cornerRadius: 24,
                    style: .continuous
                )
                .fill(
                    isListening
                        ? Color.red
                        : Color.white
                )
            }
            .shadow(
                color: isListening
                    ? Color.red.opacity(0.24)
                    : Color.black.opacity(0.2),
                radius: 18,
                y: 10
            )
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityValue(
            isListening
                ? "正在捕捉"
                : "尚未开始"
        )
    }

    private var privacySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(
                title: "隐私级别",
                detail: "戒指手势可切换"
            )

            HStack(spacing: 8) {
                ForEach(PrivacyLevel.allCases) { level in
                    PrivacyLevelButton(
                        level: level,
                        isSelected: privacyLevel == level
                    ) {
                        privacyLevel = level
                    }
                }
            }
        }
    }

    private var recentIdeasSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(
                title: "最近灵感",
                detail: "查看全部"
            )

            IdeaRow(
                title: "为什么城市夜晚适合记录声音？",
                detail: "刚刚 · 已追问 3 轮",
                symbol: "waveform"
            )

            IdeaRow(
                title: "用一天测试无屏创作工作流",
                detail: "昨天 · 已生成视频大纲",
                symbol: "wand.and.stars"
            )

            IdeaRow(
                title: "活动现场的十个临场拍摄技巧",
                detail: "周一 · 私密",
                symbol: "lock.fill"
            )
        }
    }
}

private struct PawnStatusCard: View {
    let isListening: Bool

    var body: some View {
        GlassCard {
            HStack(spacing: 16) {
                Image(
                    systemName: isListening
                        ? "waveform"
                        : "ear"
                )
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(
                    isListening
                        ? Color.red
                        : Color.white
                )
                .frame(width: 58, height: 58)
                .background(
                    isListening
                        ? Color.red.opacity(0.14)
                        : Color.white.opacity(0.08),
                    in: Circle()
                )
                .overlay {
                    Circle()
                        .strokeBorder(
                            isListening
                                ? Color.red.opacity(0.34)
                                : Color.white.opacity(0.12),
                            lineWidth: 0.8
                        )
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text(
                        isListening
                            ? "PAWN 正在聆听"
                            : "PAWN 已准备好"
                    )
                    .font(.headline)

                    Text(
                        isListening
                            ? "说出你的想法，我会继续追问"
                            : "双击 Zilo 戒指或点击下方按钮"
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }

                Spacer()

                Circle()
                    .fill(
                        isListening
                            ? Color.red
                            : Color.secondary
                    )
                    .frame(width: 8, height: 8)
                    .shadow(
                        color: isListening
                            ? Color.red.opacity(0.75)
                            : Color.clear,
                        radius: 6
                    )
            }
        }
    }
}

private struct PrivacyLevelButton: View {
    let level: PrivacyLevel
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(
                level.title,
                systemImage: level.symbol
            )
            .font(.caption.weight(.semibold))
            .foregroundStyle(
                isSelected
                    ? Color.black
                    : Color.white.opacity(0.52)
            )
            .frame(maxWidth: .infinity)
            .padding(.vertical, 11)
            .background {
                Capsule()
                    .fill(
                        isSelected
                            ? Color.white
                            : Color.white.opacity(0.055)
                    )
            }
            .overlay {
                Capsule()
                    .strokeBorder(
                        isSelected
                            ? Color.white
                            : Color.white.opacity(0.1),
                        lineWidth: 0.8
                    )
            }
        }
        .buttonStyle(PressableButtonStyle())
    }
}

// MARK: - Creation

private struct CreationDemoView: View {
    @State private var selectedFilter: ProjectFilter = .all

    var body: some View {
        DemoPageBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    filterPicker

                    ActiveCreationCard()

                    otherProjectsSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("创作")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                } label: {
                    Image(systemName: "plus")
                        .foregroundStyle(.white)
                }
                .accessibilityLabel("新建创作")
            }
        }
    }

    private var filterPicker: some View {
        Picker(
            "项目筛选",
            selection: $selectedFilter
        ) {
            ForEach(ProjectFilter.allCases) { filter in
                Text(filter.title)
                    .tag(filter)
            }
        }
        .pickerStyle(.segmented)
    }

    private var otherProjectsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(
                title: "其他项目",
                detail: "管理"
            )

            ProjectRow(
                title: "现场收音设备横评",
                detail: "等待确认标题",
                progress: 0.45
            )

            ProjectRow(
                title: "新手创作者如何找选题",
                detail: "提词稿已完成",
                progress: 1
            )
        }
    }
}

private struct ActiveCreationCard: View {
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    Label(
                        "正在创作",
                        systemImage: "wand.and.stars"
                    )
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)

                    Spacer()

                    Text("72%")
                        .font(
                            .caption
                                .monospacedDigit()
                                .weight(.semibold)
                        )
                        .foregroundStyle(.secondary)
                }

                Text("无屏创作的一天")
                    .font(.title2.bold())

                Text(
                    "PAWN 已根据 4 轮对话生成视频结构，你可以继续完善分镜和提词稿。"
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineSpacing(3)

                ProgressView(value: 0.72)
                    .tint(.white)

                HStack(spacing: 8) {
                    ResultChip(
                        title: "大纲",
                        symbol: "list.bullet",
                        isReady: true
                    )

                    ResultChip(
                        title: "分镜",
                        symbol: "rectangle.split.3x1",
                        isReady: true
                    )

                    ResultChip(
                        title: "提词稿",
                        symbol: "text.quote",
                        isReady: false
                    )
                }

                Button {
                } label: {
                    Label(
                        "继续创作",
                        systemImage: "arrow.right"
                    )
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(
                        Color.white,
                        in: RoundedRectangle(
                            cornerRadius: 12,
                            style: .continuous
                        )
                    )
                }
                .buttonStyle(PressableButtonStyle())
            }
        }
    }
}

// MARK: - Collaboration

private struct CollaborationDemoView: View {
    @State private var draftReply = ""

    @State private var messages: [DemoMessage] = [
        DemoMessage(
            text: "我已经整理了《无屏创作的一天》的初版大纲。你希望开头更偏故事感，还是直接展示戒指唤醒？",
            isAgent: true
        ),
        DemoMessage(
            text: "先用一个活动现场突然有灵感的场景开头，然后再展示戒指。",
            isAgent: false
        ),
        DemoMessage(
            text: "明白。我会把开头改成 15 秒的现场钩子，并保留同一个项目上下文。",
            isAgent: true
        )
    ]

    var body: some View {
        DemoPageBackground {
            VStack(spacing: 0) {
                messageList

                composer
            }
        }
        .navigationTitle("协作")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 1) {
                    Text("PAWN")
                        .font(.headline)

                    Text("上下文已同步")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var messageList: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                TaskContextCard()

                ForEach(messages) { message in
                    MessageBubble(message: message)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
    }

    private var composer: some View {
        HStack(spacing: 10) {
            Button {
            } label: {
                Image(systemName: "plus")
                    .frame(width: 38, height: 38)
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.circle)
            .tint(.white)

            TextField(
                "回复 PAWN…",
                text: $draftReply
            )
            .textFieldStyle(.plain)
            .padding(.horizontal, 15)
            .frame(height: 42)
            .background(
                .thinMaterial,
                in: Capsule()
            )
            .overlay {
                Capsule()
                    .strokeBorder(
                        Color.white.opacity(0.12),
                        lineWidth: 0.8
                    )
            }

            Button {
                sendMessage()
            } label: {
                Image(systemName: "arrow.up")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.black)
                    .frame(width: 38, height: 38)
                    .background(
                        draftReply.isEmpty
                            ? Color.white.opacity(0.35)
                            : Color.white,
                        in: Circle()
                    )
            }
            .disabled(draftReply.isEmpty)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }

    private func sendMessage() {
        let content = draftReply.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !content.isEmpty else {
            return
        }

        messages.append(
            DemoMessage(
                text: content,
                isAgent: false
            )
        )

        draftReply = ""
    }
}

// MARK: - Profile

private struct ProfileDemoView: View {
    @State private var localEncryptionEnabled = true
    @State private var chainProofEnabled = true

    var body: some View {
        DemoPageBackground {
            List {
                profileSection

                deviceSection

                privacySettingsSection
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("我的")
        .navigationBarTitleDisplayMode(.large)
    }

    private var profileSection: some View {
        Section {
            HStack(spacing: 16) {
                Text("P")
                    .font(.title2.bold())
                    .foregroundStyle(.black)
                    .frame(width: 58, height: 58)
                    .background(Color.white, in: Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text("PAWN Creator")
                        .font(.headline)

                    Text("12 条灵感 · 3 个创作项目")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 6)
        }
    }

    private var deviceSection: some View {
        Section("设备") {
            Label {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Zilo Whisper")

                    Text("已连接 · 电量 84%")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } icon: {
                Image(systemName: "circle.hexagongrid.fill")
                    .foregroundStyle(.green)
            }

            Label {
                VStack(alignment: .leading, spacing: 3) {
                    Text("viaim 耳机")

                    Text("已连接 · 麦克风可用")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } icon: {
                Image(systemName: "headphones")
                    .foregroundStyle(.white)
            }
        }
    }

    private var privacySettingsSection: some View {
        Section {
            Toggle(isOn: $localEncryptionEnabled) {
                Label(
                    "本地加密",
                    systemImage: "lock.fill"
                )
            }
            .tint(.blue)

            Toggle(isOn: $chainProofEnabled) {
                Label(
                    "链上授权证明",
                    systemImage: "checkmark.seal.fill"
                )
            }
            .tint(.blue)
        } header: {
            Text("记忆与授权")
        } footer: {
            Text(
                "原始内容只保存在本地，链上仅写入内容哈希和授权状态。"
            )
        }
    }
}

// MARK: - Native Tab Configuration

private enum AppTab: Hashable {
    case inspiration
    case creation
    case collaboration
    case profile

    var title: String {
        switch self {
        case .inspiration:
            return "灵感"

        case .creation:
            return "创作"

        case .collaboration:
            return "协作"

        case .profile:
            return "我的"
        }
    }

    var symbol: String {
        switch self {
        case .inspiration:
            return "sparkles"

        case .creation:
            return "wand.and.stars"

        case .collaboration:
            return "bubble.left.and.bubble.right"

        case .profile:
            return "person.crop.circle"
        }
    }
}

// MARK: - Reusable Components

private struct DemoPageBackground<Content: View>: View {
    let content: Content

    init(
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            Color(
                red: 0.018,
                green: 0.018,
                blue: 0.022
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [
                    Color.white.opacity(0.055),
                    Color.white.opacity(0.012),
                    Color.clear
                ],
                center: .topTrailing,
                startRadius: 20,
                endRadius: 460
            )
            .ignoresSafeArea()

            content
        }
    }
}

private struct GlassCard<Content: View>: View {
    let content: Content

    init(
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .background(
                Color.white.opacity(0.055),
                in: cardShape
            )
            .overlay {
                cardShape
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.17),
                                Color.white.opacity(0.045)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.8
                    )
            }
    }

    private var cardShape: RoundedRectangle {
        RoundedRectangle(
            cornerRadius: 22,
            style: .continuous
        )
    }
}

private struct SectionHeader: View {
    let title: String
    let detail: String

    var body: some View {
        HStack {
            Text(title)
                .font(.headline)

            Spacer()

            Text(detail)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

private struct IdeaRow: View {
    let title: String
    let detail: String
    let symbol: String

    var body: some View {
        GlassCard {
            HStack(spacing: 14) {
                Image(systemName: symbol)
                    .font(
                        .system(
                            size: 17,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(
                        Color.white.opacity(0.08),
                        in: RoundedRectangle(
                            cornerRadius: 13,
                            style: .continuous
                        )
                    )

                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)

                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(.tertiary)
            }
        }
    }
}

private struct ResultChip: View {
    let title: String
    let symbol: String
    let isReady: Bool

    var body: some View {
        VStack(spacing: 7) {
            Image(
                systemName: isReady
                    ? "checkmark.circle.fill"
                    : symbol
            )
            .foregroundStyle(
                isReady
                    ? Color.green
                    : Color.secondary
            )

            Text(title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            Color.white.opacity(0.045),
            in: RoundedRectangle(
                cornerRadius: 14,
                style: .continuous
            )
        )
    }
}

private struct ProjectRow: View {
    let title: String
    let detail: String
    let progress: Double

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(title)
                            .font(.subheadline.weight(.semibold))

                        Text(detail)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text("\(Int(progress * 100))%")
                        .font(
                            .caption
                                .monospacedDigit()
                                .weight(.semibold)
                        )
                        .foregroundStyle(
                            progress >= 1
                                ? Color.green
                                : Color.white
                        )
                }

                ProgressView(value: progress)
                    .tint(
                        progress >= 1
                            ? Color.green
                            : Color.white
                    )
            }
        }
    }
}

private struct TaskContextCard: View {
    var body: some View {
        GlassCard {
            HStack(spacing: 14) {
                Image(systemName: "link")
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(
                        Color.white.opacity(0.08),
                        in: Circle()
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text("无屏创作的一天")
                        .font(.subheadline.weight(.semibold))

                    Text("上下文已同步 · 4 轮对话")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("进行中")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.green)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(
                        Color.green.opacity(0.12),
                        in: Capsule()
                    )
            }
        }
    }
}

private struct MessageBubble: View {
    let message: DemoMessage

    var body: some View {
        HStack {
            if !message.isAgent {
                Spacer(minLength: 48)
            }

            VStack(alignment: .leading, spacing: 6) {
                if message.isAgent {
                    Label(
                        "PAWN",
                        systemImage: "sparkles"
                    )
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.white)
                }

                Text(message.text)
                    .font(.subheadline)
                    .lineSpacing(3)
                    .foregroundStyle(
                        message.isAgent
                            ? Color.white
                            : Color.black
                    )
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 12)
            .background(
                message.isAgent
                    ? Color.white.opacity(0.07)
                    : Color.white,
                in: RoundedRectangle(
                    cornerRadius: 18,
                    style: .continuous
                )
            )

            if message.isAgent {
                Spacer(minLength: 48)
            }
        }
    }
}

private struct PressableButtonStyle: ButtonStyle {
    func makeBody(
        configuration: Configuration
    ) -> some View {
        configuration.label
            .scaleEffect(
                configuration.isPressed
                    ? 0.97
                    : 1
            )
            .opacity(
                configuration.isPressed
                    ? 0.84
                    : 1
            )
            .animation(
                .easeOut(duration: 0.12),
                value: configuration.isPressed
            )
    }
}

// MARK: - Supporting Types

private struct DemoMessage: Identifiable {
    let id = UUID()
    let text: String
    let isAgent: Bool
}

private enum PrivacyLevel: String, CaseIterable, Identifiable {
    case privateOnly
    case authorized
    case publicContent

    var id: Self {
        self
    }

    var title: String {
        switch self {
        case .privateOnly:
            return "私密"

        case .authorized:
            return "授权"

        case .publicContent:
            return "公开"
        }
    }

    var symbol: String {
        switch self {
        case .privateOnly:
            return "lock.fill"

        case .authorized:
            return "person.badge.key.fill"

        case .publicContent:
            return "globe.asia.australia.fill"
        }
    }
}

private enum ProjectFilter: String, CaseIterable, Identifiable {
    case all
    case creating
    case completed

    var id: Self {
        self
    }

    var title: String {
        switch self {
        case .all:
            return "全部"

        case .creating:
            return "创作中"

        case .completed:
            return "已完成"
        }
    }
}

#Preview {
    ContentView()
}
