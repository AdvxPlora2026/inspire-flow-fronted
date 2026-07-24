import SwiftUI

struct AssignInspirationView: View {
    @EnvironmentObject private var appStore: AppStore
    @Environment(\.dismiss) private var dismiss

    let inspirationID: UUID

    @State private var selectedProjectID: UUID?
    @State private var isCreatingProject = false
    @State private var searchText = ""

    private var filteredProjects: [CreatorProject] {
        if searchText.isEmpty { return appStore.projects }
        return appStore.projects.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.initialIdea.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            ShengbianBackground {
                VStack(spacing: 0) {
                    searchBar

                    if filteredProjects.isEmpty {
                        emptyState
                    } else {
                        projectList
                    }

                    Spacer()

                    confirmBar
                }
            }
            .navigationTitle("指派到项目")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isCreatingProject = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("新建项目")
                }
            }
            .navigationDestination(isPresented: $isCreatingProject) {
                NewProjectView()
            }
        }
        .preferredColorScheme(.dark)
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(ShengbianColors.secondaryText)
            TextField("搜索项目", text: $searchText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
        }
        .padding(.horizontal, 14)
        .frame(height: 44)
        .background(ShengbianColors.glassTint, in: RoundedRectangle(cornerRadius: ShengbianMetrics.controlRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: ShengbianMetrics.controlRadius, style: .continuous)
                .strokeBorder(ShengbianColors.glassBorder)
        }
        .padding(.horizontal, ShengbianMetrics.pageMargin)
        .padding(.vertical, 12)
    }

    private var projectList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(filteredProjects) { project in
                    projectRow(project)
                }
            }
            .padding(.horizontal, ShengbianMetrics.pageMargin)
        }
    }

    private func projectRow(_ project: CreatorProject) -> some View {
        let isSelected = selectedProjectID == project.id

        return Button {
            selectedProjectID = isSelected ? nil : project.id
        } label: {
            HStack(spacing: 14) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? ShengbianColors.primaryText : ShengbianColors.tertiaryText)

                VStack(alignment: .leading, spacing: 4) {
                    Text(project.name)
                        .font(ShengbianTypography.bodyEmphasized)
                        .foregroundStyle(ShengbianColors.primaryText)
                    Text(project.stage.title)
                        .font(ShengbianTypography.caption)
                        .foregroundStyle(ShengbianColors.secondaryText)
                }

                Spacer()

                Label(project.kind.title, systemImage: project.kind == .commercial ? "briefcase.fill" : "person.fill")
                    .font(ShengbianTypography.caption)
                    .foregroundStyle(ShengbianColors.tertiaryText)
            }
            .padding(14)
            .background(
                isSelected ? ShengbianColors.glassTintStrong : ShengbianColors.glassTint,
                in: RoundedRectangle(cornerRadius: ShengbianMetrics.cardRadius, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: ShengbianMetrics.cardRadius, style: .continuous)
                    .strokeBorder(
                        isSelected ? ShengbianColors.primaryText.opacity(0.3) : ShengbianColors.glassBorder
                    )
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "square.stack.3d.up.slash")
                .font(.largeTitle)
                .foregroundStyle(ShengbianColors.tertiaryText)
            Text(searchText.isEmpty ? "还没有项目" : "没有匹配的项目")
                .font(ShengbianTypography.subheadline)
                .foregroundStyle(ShengbianColors.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }

    private var confirmBar: some View {
        VStack(spacing: 0) {
            Divider().background(ShengbianColors.glassBorder)

            HStack(spacing: 12) {
                if let projectID = selectedProjectID,
                   let project = appStore.projects.first(where: { $0.id == projectID }) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("已选择")
                            .font(ShengbianTypography.label)
                            .foregroundStyle(ShengbianColors.tertiaryText)
                        Text(project.name)
                            .font(ShengbianTypography.subheadline)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Text("选择一个项目")
                        .font(ShengbianTypography.subheadline)
                        .foregroundStyle(ShengbianColors.tertiaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button {
                    if let projectID = selectedProjectID {
                        appStore.assignInspiration(inspirationID, toProject: projectID)
                    }
                    dismiss()
                } label: {
                    Text("确认")
                        .font(ShengbianTypography.headline)
                        .foregroundStyle(ShengbianColors.inverseText)
                        .padding(.horizontal, 24)
                        .frame(height: 46)
                        .background(
                            selectedProjectID != nil ? ShengbianColors.primaryAction : ShengbianColors.primaryAction.opacity(0.35),
                            in: RoundedRectangle(cornerRadius: ShengbianMetrics.controlRadius, style: .continuous)
                        )
                }
                .disabled(selectedProjectID == nil)
                .buttonStyle(.plain)
            }
            .padding(.horizontal, ShengbianMetrics.pageMargin)
            .padding(.vertical, 14)
            .background(.ultraThinMaterial)
        }
    }
}

#Preview("AssignInspirationView") {
    AssignInspirationView(inspirationID: UUID())
        .environmentObject(AppStore())
}
