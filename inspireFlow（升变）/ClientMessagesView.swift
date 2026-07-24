import SwiftUI

struct ClientMessagesView: View {
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
                        Label("还没有委托会话", systemImage: "bubble.left.and.bubble.right")
                    } description: {
                        Text("发布委托后，可以在这里与 PAWN 梳理需求和方案。")
                    } actions: {
                        ShengbianPrimaryButton(title: "发布委托", symbol: "plus") {
                            isCreatingBrief = true
                        }
                        .padding(.horizontal, ShengbianMetrics.pageMargin)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(projects) { project in
                                NavigationLink {
                                    ProjectPawnWorkspaceView(projectID: project.id)
                                } label: {
                                    messageRow(project)
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
        .navigationTitle("需求助手")
        .navigationDestination(isPresented: $isCreatingBrief) {
            ClientCreateBriefView()
        }
    }

    private func messageRow(_ project: CreatorProject) -> some View {
        ShengbianGlassCard {
            HStack(spacing: 14) {
                Image(systemName: "bubble.left.and.text.bubble.right.fill")
                    .font(.headline)
                    .frame(width: 42, height: 42)
                    .background(ShengbianColors.glassTintStrong, in: RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 5) {
                    Text(project.name)
                        .font(ShengbianTypography.bodyEmphasized)
                    Text("继续梳理需求与创作方案")
                        .font(ShengbianTypography.caption)
                        .foregroundStyle(ShengbianColors.secondaryText)
                }

                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(ShengbianColors.tertiaryText)
            }
        }
    }
}
