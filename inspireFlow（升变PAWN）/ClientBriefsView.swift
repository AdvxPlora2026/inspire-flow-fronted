import SwiftUI

struct ClientBriefsView: View {
    @EnvironmentObject private var appStore: AppStore
    @State private var isCreatingBrief = false

    private var projects: [CreatorProject] {
        appStore.projects.filter { $0.kind == .commercial }
    }

    var body: some View {
        AppBackground {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(projects) { project in
                        ProjectSummaryCard(project: project) {
                            appStore.advance(project.id)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
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
}