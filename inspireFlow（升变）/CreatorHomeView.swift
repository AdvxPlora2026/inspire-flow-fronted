import SwiftUI

struct CreatorHomeView: View {
    @EnvironmentObject private var appStore: AppStore
    @EnvironmentObject private var session: AppSession
    @State private var isCreatingProject = false
    @State private var isCapturing = false

    var body: some View {
        ShengbianBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    greeting
                    captureAction
                    currentWork
                    recentInspirations
                    quickActions
                }
                .padding(.horizontal, ShengbianMetrics.pageMargin)
                .padding(.bottom, 32)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                AppBrandMark(compact: true)
            }
            ToolbarItem(placement: .topBarTrailing) {
                ShengbianIconButton(symbol: "plus", accessibilityLabel: "新建项目") {
                    isCreatingProject = true
                }
            }
        }
        .navigationDestination(isPresented: $isCreatingProject) {
            NewProjectView()
        }
        .sheet(isPresented: $isCapturing) {
            InspirationRecordView()
        }
    }

    private var greeting: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text("晚上好，\(session.displayName)")
                .font(ShengbianTypography.subheadline)
                .foregroundStyle(ShengbianColors.secondaryText)
            Text("别让这个念头消失。")
                .font(ShengbianTypography.display)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 12)
    }

    private var captureAction: some View {
        Button {
            isCapturing = true
        } label: {
            VStack(spacing: 20) {
                CaptureSignalMark()

                VStack(spacing: 6) {
                    Text("捕捉灵感")
                        .font(ShengbianTypography.title2)
                    Text("轻点开始，或双击戒指")
                        .font(ShengbianTypography.subheadline)
                        .foregroundStyle(ShengbianColors.secondaryText)
                }

                HStack(spacing: 10) {
                    Image(systemName: "waveform")
                    Text("开始说话")
                        .font(ShengbianTypography.headline)
                    Spacer()
                    Image(systemName: "arrow.right")
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
            .padding(.vertical, 24)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: ShengbianMetrics.cardRadius, style: .continuous))
            .background(
                ShengbianColors.glassTintStrong,
                in: RoundedRectangle(cornerRadius: ShengbianMetrics.cardRadius, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: ShengbianMetrics.cardRadius, style: .continuous)
                    .strokeBorder(ShengbianColors.glassHighlight, lineWidth: 0.8)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("捕捉灵感，PAWN 已准备好")
            .accessibilityHint("轻点屏幕开始说话，也可双击 Zilo 戒指")
        }
        .buttonStyle(.plain)
    }

    private struct CaptureSignalMark: View {
        var body: some View {
            ZStack {
                ForEach([1.0, 0.72, 0.44], id: \.self) { scale in
                    Circle()
                        .strokeBorder(
                            ShengbianColors.primaryText.opacity(0.08 + (1 - scale) * 0.2),
                            lineWidth: 1
                        )
                        .frame(width: 150 * scale, height: 150 * scale)
                }

                Image(systemName: "mic.fill")
                    .font(.system(size: 25, weight: .semibold))
                    .foregroundStyle(ShengbianColors.inverseText)
                    .frame(width: 66, height: 66)
                    .background(ShengbianColors.primaryAction, in: Circle())
                    .overlay {
                        Circle().strokeBorder(Color.black.opacity(0.12), lineWidth: 0.5)
                    }
            }
            .frame(height: 150)
            .accessibilityHidden(true)
        }
    }

    private var currentWork: some View {
        VStack(alignment: .leading, spacing: 12) {
            ShengbianSectionHeader(
                title: "继续创作",
                detail: "\(appStore.projects.count) 个项目"
            )

            if let project = appStore.projects.first {
                NavigationLink {
                    ProjectDetailView(projectID: project.id)
                } label: {
                    ProjectSummaryCard(project: project, showsAction: false) {}
                }
                .buttonStyle(.plain)
            } else {
                ContentUnavailableView("还没有项目", systemImage: "square.stack.3d.up.slash")
            }
        }
    }

    private var recentInspirations: some View {
        VStack(alignment: .leading, spacing: 12) {
            ShengbianSectionHeader(
                title: "最近灵感",
                detail: appStore.inspirations.count > 3 ? "查看全部" : nil
            )

            if appStore.inspirations.isEmpty {
                ShengbianGlassCard {
                    Label("还没有捕捉到灵感，轻点上方按钮开始。", systemImage: "waveform")
                        .font(ShengbianTypography.subheadline)
                        .foregroundStyle(ShengbianColors.secondaryText)
                }
            } else {
                ForEach(appStore.inspirations.prefix(3)) { inspiration in
                    NavigationLink {
                        InspirationDetailView(inspirationID: inspiration.id)
                    } label: {
                        inspirationRow(inspiration)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func inspirationRow(_ inspiration: InspirationCapture) -> some View {
        ShengbianGlassCard {
            HStack(spacing: 14) {
                Image(systemName: inspiration.bilibiliPack != nil ? "wand.and.stars" : "waveform")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(ShengbianColors.primaryText)
                    .frame(width: 40, height: 40)
                    .background(ShengbianColors.glassTintStrong, in: RoundedRectangle(cornerRadius: 8, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(inspiration.transcription.isEmpty ? "（无文字）" : inspiration.transcription)
                        .font(ShengbianTypography.subheadline)
                        .lineLimit(1)

                    HStack(spacing: 6) {
                        Text(inspiration.createdAt.formatted(.relative(presentation: .named)))
                            .font(ShengbianTypography.caption)
                            .foregroundStyle(ShengbianColors.tertiaryText)

                        if inspiration.bilibiliPack != nil {
                            Text("·")
                                .foregroundStyle(ShengbianColors.tertiaryText)
                                .font(ShengbianTypography.caption)
                            Text("已生成方案")
                                .font(ShengbianTypography.caption)
                                .foregroundStyle(ShengbianColors.success)
                        }

                        if inspiration.isDemoFallback {
                            Text("·")
                                .foregroundStyle(ShengbianColors.tertiaryText)
                                .font(ShengbianTypography.caption)
                            Text("演示")
                                .font(ShengbianTypography.technical)
                                .foregroundStyle(ShengbianColors.warning)
                        }
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(ShengbianColors.tertiaryText)
            }
        }
    }


    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 12) {
            ShengbianSectionHeader(title: "创作工具", detail: nil)

            ViewThatFits {
                HStack(spacing: 10) {
                    quickAction("提词拍摄", symbol: "text.viewfinder")
                    quickAction("导出材料", symbol: "square.and.arrow.up")
                    quickAction("设备", symbol: "dot.radiowaves.left.and.right")
                }

                VStack(spacing: 10) {
                    quickAction("提词拍摄", symbol: "text.viewfinder")
                    quickAction("导出材料", symbol: "square.and.arrow.up")
                    quickAction("设备", symbol: "dot.radiowaves.left.and.right")
                }
            }
        }
    }

    private func quickAction(_ title: String, symbol: String) -> some View {
        Button {} label: {
            VStack(spacing: 9) {
                Image(systemName: symbol).font(.headline)
                Text(title).font(.caption.weight(.semibold))
            }
            .frame(maxWidth: .infinity, minHeight: 76)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: ShengbianMetrics.controlRadius, style: .continuous))
            .background(ShengbianColors.glassTint, in: RoundedRectangle(cornerRadius: ShengbianMetrics.controlRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: ShengbianMetrics.controlRadius, style: .continuous)
                    .strokeBorder(ShengbianColors.glassBorder)
            }
        }
        .buttonStyle(.plain)
    }
}