import Combine
import Foundation

enum UserRole: String, CaseIterable, Identifiable {
    case creator
    case client

    var id: Self { self }

    var title: String {
        switch self {
        case .creator: "创作者"
        case .client: "品牌方"
        }
    }

    var detail: String {
        switch self {
        case .creator: "捕捉灵感、完成创作与交付"
        case .client: "发布需求、管理验收与结算"
        }
    }

    var symbol: String {
        switch self {
        case .creator: "wand.and.stars"
        case .client: "briefcase.fill"
        }
    }
}

@MainActor
final class AppSession: ObservableObject {
    @Published private(set) var isAuthenticated: Bool
    @Published private(set) var role: UserRole
    @Published private(set) var displayName: String
    @Published private(set) var creatorProfile: CreatorProfile
    @Published private(set) var needsCreatorProfileSetup: Bool

    private let defaults: UserDefaults
    private let authenticatedKey = "session.isAuthenticated"
    private let roleKey = "session.role"
    private let displayNameKey = "session.displayName"
    private let creatorProfileKey = "session.creatorProfile.v1"
    private let creatorProfileSetupKey = "session.needsCreatorProfileSetup"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let storedDisplayName = defaults.string(forKey: displayNameKey) ?? ""
        isAuthenticated = defaults.bool(forKey: authenticatedKey)
        role = UserRole(rawValue: defaults.string(forKey: roleKey) ?? "") ?? .creator
        displayName = storedDisplayName
        creatorProfile = defaults.data(forKey: creatorProfileKey)
            .flatMap { try? JSONDecoder().decode(CreatorProfile.self, from: $0) }
            ?? .empty(displayName: storedDisplayName)
        needsCreatorProfileSetup = defaults.bool(forKey: creatorProfileSetupKey)
    }

    func signIn(email: String, role: UserRole) {
        let accountName = email
            .split(separator: "@")
            .first
            .map(String.init) ?? "inspireFlow 用户"

        self.role = role
        displayName = accountName
        isAuthenticated = true
        persist()
    }

    func register(email: String, role: UserRole) {
        signIn(email: email, role: role)
        guard role == .creator else { return }

        creatorProfile = .empty(displayName: displayName)
        needsCreatorProfileSetup = true
        persistCreatorProfile()
    }

    func saveCreatorProfile(_ profile: CreatorProfile) {
        creatorProfile = profile
        displayName = profile.displayName.value
        needsCreatorProfileSetup = false
        persist()
        persistCreatorProfile()
    }

    func skipCreatorProfileSetup() {
        needsCreatorProfileSetup = false
        defaults.set(false, forKey: creatorProfileSetupKey)
    }

    func signOut() {
        isAuthenticated = false
        defaults.set(false, forKey: authenticatedKey)
    }

    func switchRole() {
        role = role == .creator ? .client : .creator
        defaults.set(role.rawValue, forKey: roleKey)
    }

    private func persist() {
        defaults.set(isAuthenticated, forKey: authenticatedKey)
        defaults.set(role.rawValue, forKey: roleKey)
        defaults.set(displayName, forKey: displayNameKey)
    }

    private func persistCreatorProfile() {
        if let data = try? JSONEncoder().encode(creatorProfile) {
            defaults.set(data, forKey: creatorProfileKey)
        }
        defaults.set(needsCreatorProfileSetup, forKey: creatorProfileSetupKey)
    }
}