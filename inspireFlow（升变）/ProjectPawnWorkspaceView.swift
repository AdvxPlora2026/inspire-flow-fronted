import SwiftUI
import UniformTypeIdentifiers

struct ProjectPawnWorkspaceView: View {
    @EnvironmentObject private var appStore: AppStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let projectID: UUID

    @State private var draft = ""
    @State private var isImporting = false
    @State private var generationTask: Task<Void, Never>?
    @State private var generatingMessageID: UUID?
    @State private var importError: String?

    private var project: CreatorProject? {
        appStore.projects.first { $0.id == projectID }
    }

    private var conversation: PawnConversation? {
        appStore.conversation(for: projectID)
    }

    private var isGenerating: Bool {
        generatingMessageID != nil
    }

    var body: some View {
        ShengbianBackground {
            if let project {
                VStack(spacing: 0) {
                    conversationContent(project)
                    composer(project)
                }
                .task {
                    appStore.ensureConversation(for: project)
                }
            } else {
                ContentUnavailableView(
                    "项目不可用",
                    systemImage: "exclamationmark.folder",
                    description: Text("无法载入这个项目的 PAWN 上下文。")
                )
            }
        }
        .navigationTitle("PAWN")
        .navigationBarTitleDisplayMode(.inline)
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.item],
            allowsMultipleSelection: false
        ) { result in
            handleImport(result)
        }
        .alert("无法添加附件", isPresented: importErrorBinding) {
            Button("好", role: .cancel) {}
        } message: {
            Text(importError ?? "请稍后重试。")
        }
        .onDisappear {
            stopGeneration()
        }
    }

    private func conversationContent(_ project: CreatorProject) -> some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 14) {
                    contextCard(project)

                    if let conversation {
                        ForEach(conversation.messages) { message in
                            ProjectPawnMessageBubble(message: message)
                                .id(message.id)
                        }

                        if !conversation.attachments.isEmpty {
                            attachmentSection(conversation.attachments)
                        }
                    }
                }
                .padding(.horizontal, ShengbianMetrics.pageMargin)
                .padding(.bottom, 18)
            }
            .onChange(of: conversation?.messages.count) { _, _ in
                guard let lastID = conversation?.messages.last?.id else { return }
                withAnimation(reduceMotion ? nil : .easeOut(duration: 0.2)) {
                    proxy.scrollTo(lastID, anchor: .bottom)
                }
            }
        }
    }

    private func contextCard(_ project: CreatorProject) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("项目上下文", systemImage: "link")
                    .font(ShengbianTypography.caption)
                    .foregroundStyle(ShengbianColors.secondaryText)

                Spacer()

                Text("本地演示")
                    .font(ShengbianTypography.technical)
                    .foregroundStyle(ShengbianColors.tertiaryText)
            }

            Text(project.name)
                .font(ShengbianTypography.title2)

            Text(project.initialIdea)
                .font(ShengbianTypography.subheadline)
                .foregroundStyle(ShengbianColors.secondaryText)
                .lineLimit(3)

            Label(project.stage.title, systemImage: "circle.inset.filled")
                .font(ShengbianTypography.caption)
                .foregroundStyle(ShengbianColors.primaryText)
        }
        .padding(ShengbianMetrics.cardPadding)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: ShengbianMetrics.cardRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: ShengbianMetrics.cardRadius, style: .continuous)
                .strokeBorder(ShengbianColors.glassHighlight, lineWidth: 0.8)
        }
    }

    private func attachmentSection(_ attachments: [PawnAttachment]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ShengbianSectionHeader(title: "本地附件", detail: "\(attachments.count) 项")

            ForEach(attachments) { attachment in
                HStack(spacing: 12) {
                    Image(systemName: "doc")
                        .foregroundStyle(ShengbianColors.secondaryText)
                    Text(attachment.displayName)
                        .font(ShengbianTypography.subheadline)
                        .lineLimit(1)
                    Spacer()
                    Image(systemName: "checkmark")
                        .font(.caption.bold())
                        .foregroundStyle(ShengbianColors.secondaryText)
                }
                .padding(12)
                .background(
                    ShengbianColors.glassTint,
                    in: RoundedRectangle(cornerRadius: ShengbianMetrics.controlRadius, style: .continuous)
                )
            }
        }
    }

    private func composer(_ project: CreatorProject) -> some View {
        VStack(spacing: 10) {
            if isGenerating {
                HStack(spacing: 10) {
                    Label("PAWN 正在整理本地演示回复", systemImage: "ellipsis")
                        .font(ShengbianTypography.caption)
                        .foregroundStyle(ShengbianColors.secondaryText)

                    Spacer()

                    Button("停止", action: stopGeneration)
                        .font(ShengbianTypography.caption)
                        .foregroundStyle(ShengbianColors.primaryText)
                }
            } else if let lastPawnMessage = conversation?.messages.last(where: { $0.role == .pawn }),
                      conversation?.messages.contains(where: { $0.role == .creator }) == true {
                HStack {
                    Spacer()
                    Button {
                        regenerate(after: lastPawnMessage, project: project)
                    } label: {
                        Label("重新生成", systemImage: "arrow.clockwise")
                    }
                    .font(ShengbianTypography.caption)
                    .foregroundStyle(ShengbianColors.secondaryText)
                }
            }

            HStack(alignment: .bottom, spacing: 10) {
                Button {
                    isImporting = true
                } label: {
                    Image(systemName: "paperclip")
                        .frame(width: 42, height: 42)
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.circle)
                .tint(.white)
                .accessibilityLabel("添加本地附件")

                TextField("围绕这个项目回复 PAWN…", text: $draft, axis: .vertical)
                    .textFieldStyle(.plain)
                    .lineLimit(1...4)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 11)
                    .background(
                        ShengbianColors.glassTintStrong,
                        in: RoundedRectangle(cornerRadius: ShengbianMetrics.controlRadius, style: .continuous)
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: ShengbianMetrics.controlRadius, style: .continuous)
                            .strokeBorder(ShengbianColors.glassBorder)
                    }
                    .submitLabel(.send)
                    .onSubmit {
                        send(project: project)
                    }

                Button {
                    send(project: project)
                } label: {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(ShengbianColors.inverseText)
                        .frame(width: 42, height: 42)
                        .background(
                            canSend ? ShengbianColors.primaryAction : ShengbianColors.primaryAction.opacity(0.35),
                            in: Circle()
                        )
                }
                .disabled(!canSend)
                .accessibilityLabel("发送")
            }
        }
        .padding(.horizontal, 14)
        .padding(.top, 10)
        .padding(.bottom, 8)
        .background(.ultraThinMaterial)
    }

    private var canSend: Bool {
        !isGenerating && !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var importErrorBinding: Binding<Bool> {
        Binding(
            get: { importError != nil },
            set: { if !$0 { importError = nil } }
        )
    }

    private func send(project: CreatorProject) {
        let content = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty, !isGenerating else { return }

        appStore.sendCreatorMessage(content, projectID: project.id)
        draft = ""
        generateResponse(project: project, prompt: content)
    }

    private func regenerate(after message: PawnMessage, project: CreatorProject) {
        guard !isGenerating else { return }
        appStore.removeMessage(message.id, projectID: project.id)
        let prompt = conversation?.messages.last(where: { $0.role == .creator })?.text ?? project.initialIdea
        generateResponse(project: project, prompt: prompt)
    }

    private func generateResponse(project: CreatorProject, prompt: String) {
        guard let messageID = appStore.beginPawnMessage(projectID: project.id) else { return }
        generatingMessageID = messageID

        let response = "我会把“\(prompt)”放回《\(project.name)》的上下文里。下一步先收紧开场钩子，再把它拆成大纲和可拍摄镜头。"

        if reduceMotion {
            appStore.updatePawnMessage(messageID, text: response, isComplete: true, projectID: project.id)
            generatingMessageID = nil
            return
        }

        generationTask = Task { @MainActor in
            let segments = response.split(separator: "，", omittingEmptySubsequences: false)
            var streamedText = ""

            for (index, segment) in segments.enumerated() {
                guard !Task.isCancelled else { return }
                streamedText += String(segment)
                if index < segments.count - 1 { streamedText += "，" }
                appStore.updatePawnMessage(messageID, text: streamedText, isComplete: false, projectID: project.id)
                try? await Task.sleep(for: .milliseconds(220))
            }

            guard !Task.isCancelled else { return }
            appStore.updatePawnMessage(messageID, text: response, isComplete: true, projectID: project.id)
            generatingMessageID = nil
            generationTask = nil
        }
    }

    private func stopGeneration() {
        generationTask?.cancel()
        generationTask = nil

        if let messageID = generatingMessageID,
           let text = conversation?.messages.first(where: { $0.id == messageID })?.text {
            appStore.updatePawnMessage(messageID, text: text, isComplete: true, projectID: projectID)
        }

        generatingMessageID = nil
    }

    private func handleImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            appStore.addAttachment(displayName: url.lastPathComponent, projectID: projectID)
        case .failure(let error):
            importError = error.localizedDescription
        }
    }
}

private struct ProjectPawnMessageBubble: View {
    let message: PawnMessage

    var body: some View {
        HStack {
            if message.role == .pawn {
                bubble
                Spacer(minLength: 44)
            } else {
                Spacer(minLength: 44)
                bubble
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message.role == .pawn ? "PAWN" : "你")
        .accessibilityValue(message.text.isEmpty ? "正在生成" : message.text)
    }

    private var bubble: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: message.role == .pawn ? "sparkles" : "person.fill")
                Text(message.role == .pawn ? "PAWN" : "你")
                if !message.isComplete {
                    ProgressView()
                        .controlSize(.mini)
                }
            }
            .font(ShengbianTypography.caption)
            .foregroundStyle(message.role == .pawn ? ShengbianColors.secondaryText : ShengbianColors.inverseText.opacity(0.64))

            Text(message.text.isEmpty ? "正在整理…" : message.text)
                .font(ShengbianTypography.body)
                .foregroundStyle(message.role == .pawn ? ShengbianColors.primaryText : ShengbianColors.inverseText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(
            message.role == .pawn ? AnyShapeStyle(.thinMaterial) : AnyShapeStyle(ShengbianColors.primaryAction),
            in: RoundedRectangle(cornerRadius: ShengbianMetrics.cardRadius, style: .continuous)
        )
        .overlay {
            if message.role == .pawn {
                RoundedRectangle(cornerRadius: ShengbianMetrics.cardRadius, style: .continuous)
                    .strokeBorder(ShengbianColors.glassBorder)
            }
        }
    }
}