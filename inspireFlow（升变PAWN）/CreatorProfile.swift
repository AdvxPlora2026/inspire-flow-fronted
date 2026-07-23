import Foundation

enum ProfileFieldVisibility: String, Codable, CaseIterable, Identifiable {
    case privateOnly
    case workshopPublic
    case brandsOnly
    case authorizedBrands

    var id: Self { self }

    var title: String {
        switch self {
        case .privateOnly: "仅自己"
        case .workshopPublic: "公开工作坊"
        case .brandsOnly: "品牌可见"
        case .authorizedBrands: "已授权品牌"
        }
    }
}

struct ProfileValue: Codable, Equatable {
    var value: String
    var visibility: ProfileFieldVisibility = .privateOnly
}

struct CreatorSocialAccount: Identifiable, Codable, Equatable {
    var id = UUID()
    var platform: String
    var accountName: String
    var visibility: ProfileFieldVisibility = .privateOnly
}

struct CreatorContactMethod: Identifiable, Codable, Equatable {
    var id = UUID()
    var type: String
    var value: String
    var visibility: ProfileFieldVisibility = .privateOnly
}

struct CreatorProfile: Codable, Equatable {
    var displayName: ProfileValue
    var biography = ProfileValue(value: "")
    var socialAccounts = [CreatorSocialAccount(platform: "哔哩哔哩", accountName: "")]
    var contactMethods = [CreatorContactMethod(type: "邮箱", value: "")]
    var creativeCategories = ProfileValue(value: "")
    var collaborationAvailability = ProfileValue(value: "暂不接受合作")
    var hasCompletedSetup = false

    static func empty(displayName: String) -> CreatorProfile {
        CreatorProfile(displayName: ProfileValue(value: displayName))
    }
}