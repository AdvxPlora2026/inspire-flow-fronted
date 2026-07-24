import SwiftUI

struct ClientBriefsView: View {
    @EnvironmentObject private var appStore: AppStore
    @State private var isCreatingBrief = false

    private var projects: [CreatorProject] {
        appStore.projects.filter { $0.kind == .commercial }
    }

    var body: some View {
        ShengbianBackground {
            Group {
                if projects.isEmpty {
                    ContentUnavailableView {
                        Label("还没有商业委托", systemImage: "briefcase")
                    } description: {
                        Text("发布创作需求后，委托会出现在这里。")
                    } actions: {
                        Button {
                            isCreatingBrief = true
                        } label: {
                            Text("发布委托")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.white)
                        .foregroundStyle(.black)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(projects) { project in
                                NavigationLink {
                                    ProjectDetailView(projectID: project.id)
                                } label: {
                                    briefRow(project)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, ShengbianMetrics.pageMargin)
                        .padding(.bottom, 32)
                    }
                }
            }
        }
        .navigationTitle("商业委托")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { isCreatingBrief = true } label: { Image(systemName: "plus") }
            }
        }
        .navigationDestination(isPresented: $isCreatingBrief) { ClientCreateBriefView() }
    }

    private func briefRow(_ project: CreatorProject) -> some View {
        ShengbianGlassCard {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(project.name)
                        .font(ShengbianTypography.bodyEmphasized)

                    Text(project.initialIdea)
                        .font(ShengbianTypography.caption)
                        .foregroundStyle(ShengbianColors.secondaryText)
                        .lineLimit(2)

                    ProgressView(value: project.stage.progress)
                        .tint(ShengbianColors.primaryText)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 6) {
                    Text(project.stage.title)
                        .font(ShengbianTypography.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(ShengbianColors.glassTintStrong, in: Capsule())
                        .foregroundStyle(ShengbianColors.primaryText)

                    Text("\(Int(project.stage.progress * 100))%")
                        .font(ShengbianTypography.technical)
                        .foregroundStyle(project.stage.progress >= 1 ? ShengbianColors.success : ShengbianColors.secondaryText)
                }

                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(ShengbianColors.tertiaryText)
            }
        }
    }
}