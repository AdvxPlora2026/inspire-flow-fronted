import SwiftUI

struct ClientHomeView: View {
    @EnvironmentObject private var appStore: AppStore
    @EnvironmentObject private var session: AppSession
    @State private var isCreatingBrief = false

    private var commercialProjects: [CreatorProject] {
        appStore.projects.filter { $0.kind == .commercial }
    }

    var body: some View {
        AppBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 7) {
                        Text("晚上好，\(session.displayName)")
                            .font(.title.bold())
                        Text("这里是你的商业内容工作台。")
                            .foregroundStyle(.secondary)
                    }

                    Button { isCreatingBrief = true } label: {
                        Label("发布新的创作需求", systemImage: "plus")
                            .font(.headline)
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color.white, in: RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)

                    metrics

                    VStack(alignment: .leading, spacing: 12) {
                        Text("需要处理").font(.headline)
                        ForEach(commercialProjects.prefix(2)) { project in
                            ProjectSummaryCard(project: project) {
                                appStore.advance(project.id)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
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
        AppCard {
            Text("\(value)")
                .font(.title2.monospacedDigit().bold())
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}