import SwiftUI

struct CreatorProjectsView: View {
    @EnvironmentObject private var appStore: AppStore
    @State private var isCreatingProject = false

    var body: some View {
        ShengbianBackground {
            Group {
                if appStore.projects.isEmpty {
                    ContentUnavailableView {
                        Label("还没有项目", systemImage: "square.stack.3d.up.slash")
                    } description: {
                        Text("新建项目后，PAWN 会在这里持续维护创作状态。")
                    } actions: {
                        Button {
                            isCreatingProject = true
                        } label: {
                            Text("新建项目")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.white)
                        .foregroundStyle(.black)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(appStore.projects) { project in
                                NavigationLink {
                                    ProjectDetailView(projectID: project.id)
                                } label: {
                                    ProjectSummaryCard(project: project, showsAction: false) {}
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 32)
                    }
                }
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