import SwiftUI

struct ClientHomeView: View {
    @EnvironmentObject private var appStore: AppStore
    @EnvironmentObject private var session: AppSession
    @State private var isCreatingBrief = false

    private var commercialProjects: [CreatorProject] {
        appStore.projects.filter { $0.kind == .commercial }
    }

    var body: some View {
        ShengbianBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 7) {
                        Text("晚上好，\(session.displayName)")
                            .font(ShengbianTypography.title)
                        Text("这里是你的商业内容工作台。")
                            .shengbianBodyText(secondary: true)
                    }

                    Button { isCreatingBrief = true } label: {
                        Label("发布新的创作需求", systemImage: "plus")
                            .font(ShengbianTypography.headline)
                            .foregroundStyle(ShengbianColors.inverseText)
                            .frame(maxWidth: .infinity)
                            .frame(height: ShengbianMetrics.minimumControlHeight)
                            .background(
                                ShengbianColors.primaryAction,
                                in: RoundedRectangle(cornerRadius: ShengbianMetrics.controlRadius, style: .continuous)
                            )
                    }
                    .buttonStyle(.plain)

                    metrics

                    VStack(alignment: .leading, spacing: 12) {
                        ShengbianSectionHeader(title: "需要处理", detail: "\(commercialProjects.count) 个")

                        if commercialProjects.isEmpty {
                            ShengbianGlassCard {
                                Label("还没有商业委托，发布一个需求开始合作。", systemImage: "briefcase")
                                    .font(ShengbianTypography.subheadline)
                                    .foregroundStyle(ShengbianColors.secondaryText)
                            }
                        } else {
                            ForEach(commercialProjects.prefix(3)) { project in
                                NavigationLink {
                                    ProjectDetailView(projectID: project.id)
                                } label: {
                                    commercialProjectRow(project)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(.horizontal, ShengbianMetrics.pageMargin)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("inspireFlow")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $isCreatingBrief) { ClientCreateBriefView() }
    }

    private var metrics: some View {
        HStack(spacing: 10) {
            metric("进行中", value: commercialProjects.filter { $0.stage != .settled }.count)
            metric("待验收", value: commercialProjects.filter { $0.stage == .review }.count)
            metric("已完成", value: commercialProjects.filter { $0.stage == .settled }.count)
        }
    }

    private func metric(_ title: String, value: Int) -> some View {
        ShengbianGlassCard {
            Text("\(value)")
                .font(ShengbianTypography.title2.monospacedDigit())
            Text(title)
                .font(ShengbianTypography.caption)
                .foregroundStyle(ShengbianColors.secondaryText)
        }
    }

    private func commercialProjectRow(_ project: CreatorProject) -> some View {
        ShengbianGlassCard {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(project.name)
                        .font(ShengbianTypography.bodyEmphasized)

                    Text(project.initialIdea)
                        .font(ShengbianTypography.caption)
                        .foregroundStyle(ShengbianColors.secondaryText)
                        .lineLimit(1)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 5) {
                    Text(project.stage.title)
                        .font(ShengbianTypography.caption)
                        .foregroundStyle(ShengbianColors.secondaryText)

                    Text("\(Int(project.stage.progress * 100))%")
                        .font(ShengbianTypography.technical)
                        .foregroundStyle(project.stage.progress >= 1 ? ShengbianColors.success : ShengbianColors.primaryText)
                }

                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(ShengbianColors.tertiaryText)
            }
        }
    }
}