import SwiftUI

struct InspirationDetailView: View {
    @EnvironmentObject private var appStore: AppStore
    @Environment(\.dismiss) private var dismiss

    let inspirationID: UUID

    @State private var isAssigning = false
    @State private var isConfirmingDelete = false

    private var inspiration: InspirationCapture? {
        appStore.inspirations.first { $0.id == inspirationID }
    }

    var body: some View {
        ShengbianBackground {
            if let inspiration {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        headerSection(inspiration)
                        transcriptionSection(inspiration)
                        if !inspiration.pawnQAs.isEmpty {
                            pawnQASection(inspiration)
                        }
                        if let pack = inspiration.bilibiliPack {
                            bilibiliSection(pack, isDemoFallback: inspiration.isDemoFallback)
                        }
                        projectSection(inspiration)
                        actionSection(inspiration)
                    }
                    .padding(.horizontal, ShengbianMetrics.pageMargin)
                    .padding(.vertical, 24)
                }
            } else {
                ContentUnavailableView(
                    "灵感不可用",
                    systemImage: "exclamationmark.folder",
                    description: Text("它可能已在其他位置被删除。")
                )
            }
        }
        .navigationTitle("灵感详情")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(role: .destructive) { isConfirmingDelete = true } label: {
                    Image(systemName: "trash")
                }
                .accessibilityLabel("删除灵感")
            }
        }
        .confirmationDialog("删除这条灵感？", isPresented: $isConfirmingDelete, titleVisibility: .visible) {
            Button("删除", role: .destructive) {
                appStore.deleteInspiration(inspirationID)
                dismiss()
            }
        } message: {
            Text("删除后无法恢复。")
        }
        .sheet(isPresented: $isAssigning) {
            AssignInspirationView(inspirationID: inspirationID)
        }
    }

    private func headerSection(_ inspiration: InspirationCapture) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Label(inspiration.privacy.title, systemImage: inspiration.privacy.symbol)
                    .font(ShengbianTypography.caption)
                    .foregroundStyle(ShengbianColors.secondaryText)

                if inspiration.isDemoFallback {
                    ShengbianStatusLabel(title: "演示数据", symbol: "info.circle", state: .warning)
                }

                Spacer()

                Text(inspiration.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(ShengbianTypography.technical)
                    .foregroundStyle(ShengbianColors.tertiaryText)
            }
        }
    }

    private func transcriptionSection(_ inspiration: InspirationCapture) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ShengbianSectionHeader(title: "原始灵感", detail: nil)

            ShengbianGlassCard(emphasis: .prominent) {
                VStack(alignment: .leading, spacing: 10) {
                    Image(systemName: "quote.opening")
                        .font(.title3)
                        .foregroundStyle(ShengbianColors.secondaryText)

                    Text(inspiration.transcription.isEmpty ? "（无文字内容）" : inspiration.transcription)
                        .font(ShengbianTypography.bodyEmphasized)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private func pawnQASection(_ inspiration: InspirationCapture) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ShengbianSectionHeader(title: "PAWN 三问", detail: "\(inspiration.pawnQAs.count) 轮")

            ShengbianGlassCard {
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(inspiration.pawnQAs) { qa in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(qa.question)
                                .font(ShengbianTypography.caption)
                                .foregroundStyle(ShengbianColors.secondaryText)
                            Text(qa.answer)
                                .font(ShengbianTypography.subheadline)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
        }
    }

    private func bilibiliSection(_ pack: BilibiliPack, isDemoFallback: Bool) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ShengbianSectionHeader(title: "Bilibili 创作方案", detail: nil)

            ShengbianGlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    packRow(label: "标题", value: pack.title)
                    packRow(label: "3 秒钩子", value: pack.hook)
                    packRow(label: "结构大纲", value: pack.outline)
                    packRow(label: "拍摄清单", value: pack.shotList)
                }
            }

            let shareText = buildShareText(pack: pack, qas: appStore.inspirations.first { $0.id == inspirationID }?.pawnQAs ?? [])
            ShareLink(item: shareText) {
                HStack(spacing: 10) {
                    Text("导出创作方案")
                        .font(ShengbianTypography.headline)
                    Spacer()
                    Image(systemName: "square.and.arrow.up")
                        .font(.subheadline.weight(.bold))
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

    private func projectSection(_ inspiration: InspirationCapture) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ShengbianSectionHeader(title: "所属项目", detail: nil)

            if let projectID = inspiration.projectID,
               let project = appStore.projects.first(where: { $0.id == projectID }) {
                ShengbianGlassCard {
                    HStack(spacing: 12) {
                        Image(systemName: "square.stack.3d.up.fill")
                            .foregroundStyle(ShengbianColors.secondaryText)
                        Text(project.name)
                            .font(ShengbianTypography.bodyEmphasized)
                        Spacer()
                        Text(project.stage.title)
                            .font(ShengbianTypography.caption)
                            .foregroundStyle(ShengbianColors.secondaryText)
                    }
                }
            } else {
                Button {
                    isAssigning = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "plus")
                        Text("指派到项目")
                            .font(ShengbianTypography.headline)
                        Spacer()
                    }
                    .foregroundStyle(ShengbianColors.primaryText)
                    .padding(.horizontal, 16)
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
    }

    private func actionSection(_ inspiration: InspirationCapture) -> some View {
        VStack(spacing: 10) {
            if inspiration.projectID != nil {
                Button {
                    isAssigning = true
                } label: {
                    Label("更换所属项目", systemImage: "arrow.triangle.2.circlepath")
                        .font(ShengbianTypography.subheadline)
                        .foregroundStyle(ShengbianColors.secondaryText)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
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
