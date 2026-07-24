import Foundation

// MARK: - DTOs (matches live /openapi.json from platform.advx.uk)

struct UserProfilePublicDTO: Decodable {
    let userID: UUID
    let bio: String?
    let timezone: String?
    let preferredLanguage: String?
    let creatorIdentity: String?
    let contentFocus: [String]
    let collaborationPreferences: String?
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case bio, timezone
        case preferredLanguage = "preferred_language"
        case creatorIdentity = "creator_identity"
        case contentFocus = "content_focus"
        case collaborationPreferences = "collaboration_preferences"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

private struct UserProfileUpdateDTO: Encodable {
    var bio: String? = nil
    var timezone: String? = nil
    var preferredLanguage: String? = nil
    var creatorIdentity: String? = nil
    var contentFocus: [String]? = nil
    var collaborationPreferences: String? = nil

    enum CodingKeys: String, CodingKey {
        case bio, timezone
        case preferredLanguage = "preferred_language"
        case creatorIdentity = "creator_identity"
        case contentFocus = "content_focus"
        case collaborationPreferences = "collaboration_preferences"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        // Only encode non-nil fields; a null in JSON clears the field server-side.
        try container.encodeIfPresent(bio, forKey: .bio)
        try container.encodeIfPresent(timezone, forKey: .timezone)
        try container.encodeIfPresent(preferredLanguage, forKey: .preferredLanguage)
        try container.encodeIfPresent(creatorIdentity, forKey: .creatorIdentity)
        try container.encodeIfPresent(contentFocus, forKey: .contentFocus)
        try container.encodeIfPresent(collaborationPreferences, forKey: .collaborationPreferences)
    }
}

// MARK: - Profile API

enum ProfileAPI {
    /// Fetch the current user's creator profile.
    static func get(accessToken: String) async throws -> UserProfilePublicDTO {
        try await APIClient.shared.send("users/me/profile", accessToken: accessToken)
    }

    /// Patch one or more profile fields. Passing `nil` for a field omits it from
    /// the request (the server leaves it unchanged); to clear a field, pass an
    /// explicit empty string or empty array as appropriate.
    static func update(
        accessToken: String,
        bio: String? = nil,
        timezone: String? = nil,
        preferredLanguage: String? = nil,
        creatorIdentity: String? = nil,
        contentFocus: [String]? = nil,
        collaborationPreferences: String? = nil
    ) async throws -> UserProfilePublicDTO {
        let body = try BackendJSON.encoder.encode(
            UserProfileUpdateDTO(
                bio: bio,
                timezone: timezone,
                preferredLanguage: preferredLanguage,
                creatorIdentity: creatorIdentity,
                contentFocus: contentFocus,
                collaborationPreferences: collaborationPreferences
            )
        )
        return try await APIClient.shared.send("users/me/profile", method: "PATCH", body: body, accessToken: accessToken)
    }
}
