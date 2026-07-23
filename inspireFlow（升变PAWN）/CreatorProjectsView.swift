import SwiftUI

struct CreatorProjectsView: View {
    @EnvironmentObject private var appStore: AppStore
    @State private var isCreatingProject = false

    var body: some View {
        AppBackground {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(appStore.projects) { project in
                        ProjectSummaryCard(project: project) {
                            appStore.advance(project.id)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("创作项目")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { isCreatingProject = true } label: { Image(systemName: "plus") }
            }
        }
        .navigationDestination(isPresented: $isCreatingProject) { NewProjectView() }
    }
}