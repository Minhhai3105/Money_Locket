import Foundation

struct User: Identifiable, Codable, Hashable {
    let id: UUID
    let username: String
    let displayName: String?
    let avatarUrl: String?
    let createdAt: Date
    
    static let mock = User(
        id: UUID(),
        username: "locket_fan",
        displayName: "Alex Carter",
        avatarUrl: nil,
        createdAt: Date()
    )
}
