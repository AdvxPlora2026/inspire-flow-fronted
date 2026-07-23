import Combine
import Foundation

enum ProjectKind: String, Codable, CaseIterable, Identifiable {
    case personal
    case commercial

    var id: String { rawValue }

    var title: String {
        switch self {
        case .personal: "个人创作"
        case .commercial: "商业委托"
        }
    }
}

enum ProjectStage: String, Codable, CaseIterable {
    case brief
    case creating
    case review
    case approved
    case settled

    var title: String {
        switch self {
        case .brief: "需求确认"
        case .creating: "创作中"
        case .review: "待验收"
        case .approved: "已验收"
        case .settled: "已结算"
        }
    }

    var progress: Double {
        switch self {
        case .brief: 0.15
        case .creating: 0.45
        case .review: 0.7
        case .approved: 0.9
        case .settled: 1
        }
    }

    var actionTitle: String {
        switch self {
        case .brief: "开始创作"
        case .creating: "提交验收"
        case .review: "确认验收"
        case .approved: "确认结算"
        case .settled: "已完成"
        }
    }
}

struct CreatorProject: Codable, Identifiable, Hashable {
    let id: UUID
    var name: String
    var initialIdea: String
    var kind: ProjectKind
    var stage: ProjectStage
    var createdAt: Date

    static let demo = CreatorProject(
        id: UUID(),
        name: "AdventureX 创作幕后",
        initialIdea: "记录用戒指捕捉灵感，再由 PAWN 完成 B 站创作方案的全过程。",
        kind: .commercial,
        stage: .creating,
        createdAt: .now
    )
}

@MainActor
final class AppStore: ObservableObject {
    @Published private(set) var projects: [CreatorProject]

    private let storageKey = "creatorProjects.v1"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([CreatorProject].self, from: data) {
            projects = decoded
        } else {
            projects = [.demo]
        }
    }

    @discardableResult
    func createProject(name: String, initialIdea: String, kind: ProjectKind = .personal) -> CreatorProject {
        let project = CreatorProject(
            id: UUID(),
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            initialIdea: initialIdea.trimmingCharacters(in: .whitespacesAndNewlines),
            kind: kind,
            stage: .brief,
            createdAt: .now
        )
        projects.insert(project, at: 0)
        persist()
        return project
    }

    func advance(_ projectID: UUID) {
        guard let index = projects.firstIndex(where: { $0.id == projectID }) else { return }
        let nextStage: ProjectStage
        switch projects[index].stage {
        case .brief: nextStage = .creating
        case .creating: nextStage = .review
        case .review: nextStage = .approved
        case .approved: nextStage = .settled
        case .settled: return
        }
        projects[index].stage = nextStage
        persist()
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(projects) else { return }
        defaults.set(data, forKey: storageKey)
    }
}