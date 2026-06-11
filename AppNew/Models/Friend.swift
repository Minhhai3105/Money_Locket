import Foundation

struct FriendRelationship: Identifiable, Codable, Hashable {
    let id: UUID
    let friendUser: User
    let status: FriendshipStatus
    let createdAt: Date
    
    enum FriendshipStatus: String, Codable {
        case pending
        case accepted
        case blocked
    }
}
