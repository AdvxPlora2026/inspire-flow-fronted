import SwiftUI

struct CreatorHomeView: View {
    @EnvironmentObject private var appStore: AppStore
    @EnvironmentObject private var session: AppSession
    @State private var isCreatingProject = false

    var body: some View {
        AppBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    greeting
                    captureAction
                    currentWork
                    quickActions
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("inspireFlow")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { isCreatingProject = true } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("新建项目")
            }
        }
        .navigationDestination(isPresented: $isCreatingProject) {
            NewProjectView()
        }
    }

    private var greeting: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text("晚上好，\(session.displayName)")
                .font(.title.bold())
            Text("先接住灵感，再决定它会成为什么。")
                .foregroundStyle(.secondary)
        }
        .padding(.top, 12)
    }

    private var captureAction: some View {
        NavigationLink {
            InspirationDemoView()
        } label: {
            HStack(spacing: 16) {
                Image(systemName: "waveform")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.black)
                    .frame(width: 52, height: 52)
                    .background(Color.white, in: RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 5) {
                    Text("捕捉一个新灵感")
                        .font(.headline)
                    Text("通过戒指或耳机唤醒 PAWN")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
                Image(systemName: "arrow.right")
            }
            .foregroundStyle(.white)
            .padding(16)
            .background(Color.cyan.opacity(0.16), in: RoundedRectangle(cornerRadius: 8))
            .overlay { RoundedRectangle(cornerRadius: 8).strokeBorder(Color.cyan.opacity(0.35)) }
        }
        .buttonStyle(.plain)
    }

    private var currentWork: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("继续创作").font(.headline)
                Spacer()
                Text("\(appStore.projects.count) 个项目")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let project = appStore.projects.first {
                ProjectSummaryCard(project: project) {
                    appStore.advance(project.id)
                }
            } else {
                ContentUnavailableView("还没有项目", systemImage: "square.stack.3d.up.slash")
            }
        }
    }

    private var quickActions: some View {
        HStack(spacing: 10) {
            quickAction("提词拍摄", symbol: "text.viewfinder")
            quickAction("导出材料", symbol: "square.and.arrow.up")
            quickAction("设备", symbol: "dot.radiowaves.left.and.right")
        }
    }

    private func quickAction(_ title: String, symbol: String) -> some View {
        Button {} label: {
            VStack(spacing: 9) {
                Image(systemName: symbol).font(.headline)
                Text(title).font(.caption.weight(.semibold))
            }
            .frame(maxWidth: .infinity, minHeight: 76)
            .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}