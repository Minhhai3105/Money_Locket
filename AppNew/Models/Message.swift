import Foundation

struct Message: Identifiable, Codable, Hashable {
    let id: UUID
    let senderId: UUID
    let receiverId: UUID
    let textContent: String?
    let photoUrl: String?
    let transactionId: UUID?
    let createdAt: Date
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: createdAt)
    }
    
    static func mock(text: String, isSender: Bool, minutesAgo: Int = 0) -> Message {
        let currentUserId = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        let friendId = UUID(uuidString: "11111111-1111-1111-1111-111111111111")!
        
        return Message(
            id: UUID(),
            senderId: isSender ? currentUserId : friendId,
            receiverId: isSender ? friendId : currentUserId,
            textContent: text,
            photoUrl: nil,
            transactionId: nil,
            createdAt: Calendar.current.date(byAdding: .minute, value: -minutesAgo, to: Date()) ?? Date()
        )
    }
}
