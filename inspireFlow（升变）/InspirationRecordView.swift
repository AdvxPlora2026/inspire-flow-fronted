import SwiftUI

struct InspirationRecordView: View {
    @EnvironmentObject private var appStore: AppStore
    @EnvironmentObject private var ring: RingManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var projectID: UUID?

    @State private var phase: RecordPhase = .ready
    @State private var elapsed: TimeInterval = 0
    @State private var transcription = ""
    @State private var questionIndex = 0
    @State private var answers: [String] = []
    @State private var privacy: InspirationPrivacy = .privateOnly
    @State private var timer: Timer?
    @State private var savedCapture: InspirationCapture?
    @State private var pulse = false

    private let questions = [
        "这条视频最想讲给谁看？",
        "你希望它是什么形式？",
        "最重要的开场画面是什么？"
    ]

    private let demoAnswers = [
        "第一次尝试无屏创作的 B 站创作者",
        "60 秒现场竖屏短视频",
        "创作者正在拍摄，却突然冒出一个灵感"
    ]

    var body: some View {
        ShengbianBackground {
            VStack(spacing: 0) {
                toolbar
                    .padding(.horizontal, ShengbianMetrics.pageMargin)
                    .padding(.top, 16)

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        switch phase {
                        case .ready:
                            readySection
                                .transition(sectionTransition)
                        case .recording:
                            recordingSection
                                .transition(sectionTransition)
                        case .questioning:
                            questioningSection
                                .transition(sectionTransition)
                        case .generating:
                            generatingSection
                                .transition(sectionTransition)
                        case .done:
                            if let capture = savedCapture {
                                doneSection(capture)
                                    .transition(sectionTransition)
                            }
                        }
                    }
                    .padding(.horizontal, ShengbianMetrics.pageMargin)
                    .padding(.vertical, 24)
                }

                if phase == .ready {
                    bottomBar
                }
            }
        }
        .preferredColorScheme(.dark)
        .onDisappear { stopTimer() }
        .onReceive(ring.captureSignal) { handleCaptureToggle() }
    }

    private var sectionTransition: AnyTransition {
        if reduceMotion { return .opacity }
        return .opacity.combined(with: .move(edge: .bottom))
    }

    // MARK: - Toolbar

    private var toolbar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .semibold))
                    .frame(width: 36, height: 36)
                    .background(ShengbianColors.glassTint, in: Circle())
            }
            .accessibilityLabel("关闭")

            Spacer()

            AppBrandMark(compact: true)

            Spacer()

            privacyMenu
        }
    }

    private var privacyMenu: some View {
        Menu {
            ForEach(InspirationPrivacy.allCases) { level in
                Button {
                    privacy = level
                } label: {
                    Label(level.title, systemImage: level.symbol)
                }
            }
        } label: {
            Label(privacy.title, systemImage: privacy.symbol)
                .font(ShengbianTypography.caption)
                .foregroundStyle(ShengbianColors.secondaryText)
                .padding(.horizontal, 10)
                .frame(height: 32)
                .background(ShengbianColors.glassTint, in: Capsule())
                .overlay { Capsule().strokeBorder(ShengbianColors.glassBorder) }
        }
        .accessibilityLabel("隐私设置，当前：\(privacy.title)")
    }

    // MARK: - Ready

    private var readySection: some View {
        VStack(alignment: .leading, spacing: 28) {
            VStack(alignment: .leading, spacing: 8) {
                Text("捕捉灵感")
                    .font(ShengbianTypography.display)
                Text("说出刚刚想到的，PAWN 会帮你记下来，然后问三个问题。")
                    .shengbianBodyText(secondary: true)
            }

            captureButton(isListening: false)

            demoFallbackNote
        }
    }

    // MARK: - Recording

    private var recordingSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                ShengbianStatusLabel(title: "正在录制", symbol: "waveform", state: .listening)
                Spacer()
                Text(formattedElapsed)
                    .font(ShengbianTypography.metric)
                    .foregroundStyle(ShengbianColors.secondaryText)
                    .contentTransition(.numericText())
                    .accessibilityLabel("录制时长 \(formattedElapsed)")
            }

            captureButton(isListening: true)

            ShengbianGlassCard {
                VStack(alignment: .leading, spacing: 10) {
                    Label("实时转录（演示模式）", systemImage: "text.bubble")
                        .font(ShengbianTypography.caption)
                        .foregroundStyle(ShengbianColors.tertiaryText)

                    Text(transcription.isEmpty ? "正在聆听…" : transcription)
                        .font(ShengbianTypography.body)
                        .foregroundStyle(transcription.isEmpty ? ShengbianColors.tertiaryText : ShengbianColors.primaryText)
                        .fixedSize(horizontal: false, vertical: true)
                        .animation(reduceMotion ? nil : .easeOut(duration: 0.15), value: transcription)
                }
            }
        }
    }

    // MARK: - PAWN Questioning

    private var questioningSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                ShengbianStatusLabel(title: "PAWN 追问", symbol: "sparkles", state: .neutral)
                Spacer()
                Text("\(questionIndex + 1) / \(questions.count)")
                    .font(ShengbianTypography.technical)
                    .foregroundStyle(ShengbianColors.secondaryText)
                    .contentTransition(.numericText())
            }

            ShengbianGlassCard(emphasis: .prominent) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(questions[questionIndex])
                        .font(ShengbianTypography.title3)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("通过耳机语音回答，或使用演示答案：")
                        .font(ShengbianTypography.caption)
                        .foregroundStyle(ShengbianColors.tertiaryText)
                }
            }

            Button {
                submitAnswer(demoAnswers[questionIndex])
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "waveform")
                    Text(demoAnswers[questionIndex])
                        .font(ShengbianTypography.bodyEmphasized)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .foregroundStyle(ShengbianColors.inverseText)
                .padding(14)
                .background(
                    ShengbianColors.primaryAction,
                    in: RoundedRectangle(cornerRadius: ShengbianMetrics.controlRadius, style: .continuous)
                )
            }
            .buttonStyle(.plain)
            .accessibilityHint("使用演示答案回答此问题")

            if !answers.isEmpty {
                previousAnswers
            }
        }
    }

    private var previousAnswers: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("已回答")
                .font(ShengbianTypography.caption)
                .foregroundStyle(ShengbianColors.tertiaryText)

            ForEach(Array(answers.enumerated()), id: \.offset) { index, answer in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(ShengbianColors.success)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(questions[index])
                            .font(ShengbianTypography.caption)
                            .foregroundStyle(ShengbianColors.tertiaryText)
                        Text(answer)
                            .font(ShengbianTypography.subheadline)
                    }
                }
            }
        }
    }

    // MARK: - Generating

    private var generatingSection: some View {
        VStack(spacing: 32) {
            Spacer(minLength: 40)

            VStack(spacing: 16) {
                ProgressView()
                    .controlSize(.large)
                    .tint(.white)

                Text("PAWN 正在生成 Bilibili 创作方案…")
                    .font(ShengbianTypography.subheadline)
                    .foregroundStyle(ShengbianColors.secondaryText)
                    .multilineTextAlignment(.center)
            }

            demoFallbackNote

            Spacer(minLength: 40)
        }
        .frame(maxWidth: .infinity)
        .task { await simulateGeneration() }
    }

    // MARK: - Done

    private func doneSection(_ capture: InspirationCapture) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                ShengbianStatusLabel(title: "创作方案已生成", symbol: "checkmark.circle.fill", state: .success)
                if capture.isDemoFallback {
                    ShengbianStatusLabel(title: "演示数据", symbol: "info.circle", state: .warning)
                }
            }

            if let pid = capture.projectID,
               let project = appStore.projects.first(where: { $0.id == pid }) {
                HStack(spacing: 8) {
                    Image(systemName: "square.stack.3d.up.fill")
                        .font(.caption)
                        .foregroundStyle(ShengbianColors.secondaryText)
                    Text("已保存到《\(project.name)》")
                        .font(ShengbianTypography.caption)
                        .foregroundStyle(ShengbianColors.secondaryText)
                    Spacer()
                }
                .padding(.horizontal, 2)
            }

            if let pack = capture.bilibiliPack {
                bilibiliPackCard(pack)
            }

            pawnQACard(capture.pawnQAs)

            shareAndSaveButtons(capture)
        }
    }

    private func bilibiliPackCard(_ pack: BilibiliPack) -> some View {
        ShengbianGlassCard(emphasis: .prominent) {
            VStack(alignment: .leading, spacing: 14) {
                Text("Bilibili 创作方案")
                    .font(ShengbianTypography.headline)

                packRow(label: "标题", value: pack.title)
                packRow(label: "3 秒钩子", value: pack.hook)
                packRow(label: "结构大纲", value: pack.outline)
                packRow(label: "拍摄清单", value: pack.shotList)
            }
        }
    }

    private func packRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label)
                .font(ShengbianTypography.label)
                .foregroundStyle(ShengbianColors.secondaryText)
            Text(value)
                .font(ShengbianTypography.subheadline)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func pawnQACard(_ qas: [PawnQA]) -> some View {
        ShengbianGlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("PAWN 三问记录")
                    .font(ShengbianTypography.headline)

                ForEach(qas) { qa in
                    VStack(alignment: .leading, spacing: 3) {
                        Text(qa.question)
                            .font(ShengbianTypography.caption)
                            .foregroundStyle(ShengbianColors.secondaryText)
                        Text(qa.answer)
                            .font(ShengbianTypography.subheadline)
                    }
                }
            }
        }
    }

    private func shareAndSaveButtons(_ capture: InspirationCapture) -> some View {
        VStack(spacing: 10) {
            if let pack = capture.bilibiliPack {
                let shareText = buildShareText(pack: pack, qas: capture.pawnQAs)
                ShareLink(item: shareText) {
                    HStack(spacing: 10) {
                        Text("导出 Bilibili 方案")
                            .font(ShengbianTypography.headline)
                        Spacer()
                        Image(systemName: "square.and.arrow.up")
                    }
                    .foregroundStyle(ShengbianColors.inverseText)
                    .padding(.horizontal, 18)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: ShengbianMetrics.minimumControlHeight)
                    .background(
                        ShengbianColors.primaryAction,
                        in: RoundedRectangle(cornerRadius: ShengbianMetrics.controlRadius, style: .continuous)
                    )
                }
                .buttonStyle(.plain)
            }

            Button {
                dismiss()
            } label: {
                Text("完成")
                    .font(ShengbianTypography.headline)
                    .foregroundStyle(ShengbianColors.primaryText)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: ShengbianMetrics.minimumControlHeight)
                    .background(
                        ShengbianColors.glassTintStrong,
                        in: RoundedRectangle(cornerRadius: ShengbianMetrics.controlRadius, style: .continuous)
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: ShengbianMetrics.controlRadius, style: .continuous)
                            .strokeBorder(ShengbianColors.glassBorder)
                    }
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Capture Button

    private func captureButton(isListening: Bool) -> some View {
        Button {
            handleCaptureToggle()
        } label: {
            VStack(spacing: 20) {
                ZStack {
                    ForEach(isListening ? [1.0, 0.72] : [1.0], id: \.self) { scale in
                        Circle()
                            .strokeBorder(
                                isListening
                                    ? ShengbianColors.listening.opacity(0.18 + (1 - scale) * 0.2)
                                    : ShengbianColors.primaryText.opacity(0.08),
                                lineWidth: 1
                            )
                            .frame(width: 140 * scale, height: 140 * scale)
                            .scaleEffect(isListening && pulse && !reduceMotion ? 1.08 : 1)
                            .opacity(isListening && pulse && !reduceMotion ? 0.55 : 1)
                    }

                    Image(systemName: isListening ? "stop.fill" : "mic.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(isListening ? ShengbianColors.listening : ShengbianColors.inverseText)
                        .contentTransition(.symbolEffect(.replace))
                        .frame(width: 64, height: 64)
                        .background(
                            isListening ? ShengbianColors.listening.opacity(0.18) : ShengbianColors.primaryAction,
                            in: Circle()
                        )
                }
                .frame(height: 140)
                .animation(
                    reduceMotion ? nil : ShengbianMotion.pulse.repeatForever(autoreverses: true),
                    value: pulse
                )
                .accessibilityHidden(true)

                Text(isListening ? "轻点停止录制" : "轻点开始说话")
                    .font(ShengbianTypography.headline)
                Text(isListening ? "停止后进入 PAWN 追问" : "也可以双击 Zilo 戒指唤醒")
                    .font(ShengbianTypography.caption)
                    .foregroundStyle(ShengbianColors.secondaryText)
            }
            .foregroundStyle(ShengbianColors.primaryText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: ShengbianMetrics.cardRadius, style: .continuous))
            .background(ShengbianColors.glassTintStrong, in: RoundedRectangle(cornerRadius: ShengbianMetrics.cardRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: ShengbianMetrics.cardRadius, style: .continuous)
                    .strokeBorder(
                        isListening ? ShengbianColors.listening.opacity(0.5) : ShengbianColors.glassHighlight,
                        lineWidth: isListening ? 1.25 : 0.8
                    )
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isListening ? "停止录制" : "开始录制")
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        VStack(spacing: 0) {
            Divider().background(ShengbianColors.glassBorder)

            HStack {
                Text("麦克风权限已获取（演示模式）")
                    .font(ShengbianTypography.caption)
                    .foregroundStyle(ShengbianColors.tertiaryText)
                Spacer()
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(ShengbianColors.success)
                    .font(.caption)
            }
            .padding(.horizontal, ShengbianMetrics.pageMargin)
            .padding(.vertical, 10)
        }
    }

    private var demoFallbackNote: some View {
        Label("演示数据：实际使用时将调用真实语音识别", systemImage: "info.circle")
            .font(ShengbianTypography.technical)
            .foregroundStyle(ShengbianColors.tertiaryText)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Logic

    private var formattedElapsed: String {
        let minutes = Int(elapsed) / 60
        let seconds = Int(elapsed) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private func handleCaptureToggle() {
        switch phase {
        case .ready:
            startRecording()
        case .recording:
            stopRecording()
        default:
            break
        }
    }

    private func startRecording() {
        Haptics.impact(.medium)
        withAnimation(reduceMotion ? nil : .spring(response: 0.32, dampingFraction: 0.84)) {
            phase = .recording
        }
        pulse = true
        elapsed = 0
        simulateTranscription()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            Task { @MainActor in
                elapsed += 1
            }
        }
    }

    private func stopRecording() {
        stopTimer()
        pulse = false
        Haptics.impact(.rigid)
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.18)) {
            phase = .questioning
            questionIndex = 0
            answers = []
        }
    }

    private func simulateTranscription() {
        let demo = "我想做一期关于随手用语音捕捉灵感、再由 PAWN 完成 B 站创作方案的视频。"
        var index = demo.startIndex

        Task { @MainActor in
            while index < demo.endIndex {
                guard phase == .recording else { return }
                let next = demo.index(after: index)
                transcription += String(demo[index..<next])
                index = next
                try? await Task.sleep(for: .milliseconds(60))
            }
        }
    }

    private func submitAnswer(_ answer: String) {
        Haptics.selection()
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.18)) {
            answers.append(answer)
            if questionIndex < questions.count - 1 {
                questionIndex += 1
            } else {
                phase = .generating
            }
        }
    }

    private func simulateGeneration() async {
        try? await Task.sleep(for: .seconds(2))

        let qas = zip(questions, answers.prefix(3)).map { q, a in
            PawnQA(id: UUID(), question: q, answer: a)
        }

        let pack = BilibiliPack(
            title: "我用一句话，接住了差点消失的灵感",
            hook: "最好的创作工具，也许根本没有屏幕。",
            outline: "灵感丢失 → 一句话录下 → PAWN 追问 → 成片",
            shotList: "现场走拍、开口瞬间、追问反馈、方案结果页"
        )

        let capture = appStore.addInspiration(
            transcription: transcription.isEmpty ? "（演示转录）" : transcription,
            pawnQAs: qas,
            bilibiliPack: pack,
            projectID: projectID,
            privacy: privacy,
            isDemoFallback: true
        )

        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.2)) {
            savedCapture = capture
            phase = .done
        }
        Haptics.success()
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func buildShareText(pack: BilibiliPack, qas: [PawnQA]) -> String {
        var lines = [
            "【升变 PAWN · Bilibili 创作方案】",
            "",
            "标题：\(pack.title)",
            "3 秒钩子：\(pack.hook)",
            "结构大纲：\(pack.outline)",
            "拍摄清单：\(pack.shotList)",
            "",
            "PAWN 三问："
        ]
        for qa in qas {
            lines.append("Q：\(qa.question)")
            lines.append("A：\(qa.answer)")
        }
        return lines.joined(separator: "\n")
    }
}

// MARK: - Phase

private enum RecordPhase {
    case ready
    case recording
    case questioning
    case generating
    case done
}

#Preview("InspirationRecordView") {
    InspirationRecordView()
        .environmentObject(AppStore())
        .environmentObject(RingManager())
}
