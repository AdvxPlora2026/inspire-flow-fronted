import Foundation

struct PawnConversation: Codable, Identifiable, Hashable {
    let id: UUID
    let projectID: UUID
    var messages: [PawnMessage]
    var attachments: [PawnAttachment]
    var updatedAt: Date
}

struct PawnMessage: Codable, Identifiable, Hashable {
    enum Role: String, Codable {
        case creator
        case pawn
    }

    let id: UUID
    let role: Role
    var text: String
    let createdAt: Date
    var isComplete: Bool
}

struct PawnAttachment: Codable, Identifiable, Hashable {
    let id: UUID
    let displayName: String
    let importedAt: Date
}