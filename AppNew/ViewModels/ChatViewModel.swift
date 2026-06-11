import SwiftUI
import Combine

struct Conversation: Identifiable, Hashable {
    let id: UUID
    let friend: User
    var messages: [Message]
    
    var lastMessage: String {
        messages.last?.textContent ?? "Đã gửi một ảnh locket"
    }
    
    var lastUpdated: Date {
        messages.last?.createdAt ?? Date()
    }
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: lastUpdated)
    }
}

class ChatViewModel: ObservableObject {
    @Published var conversations: [Conversation] = []
    
    init() {
        loadMockChats()
    }
    
    func sendMessage(text: String, to conversationId: UUID) {
        guard let index = conversations.firstIndex(where: { $0.id == conversationId }) else { return }
        
        let newMsg = Message(
            id: UUID(),
            senderId: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
            receiverId: conversations[index].friend.id,
            textContent: text,
            photoUrl: nil,
            transactionId: nil,
            createdAt: Date()
        )
        
        DispatchQueue.main.async {
            self.conversations[index].messages.append(newMsg)
        }
    }
    
    private func loadMockChats() {
        let friend1 = User(id: UUID(), username: "linh_dan", displayName: "Linh Đan", avatarUrl: "https://picsum.photos/150/150?random=1", createdAt: Date())
        let friend2 = User(id: UUID(), username: "minh_quan", displayName: "Minh Quân", avatarUrl: "https://picsum.photos/150/150?random=2", createdAt: Date())
        let friend3 = User(id: UUID(), username: "huong_giang", displayName: "Hương Giang", avatarUrl: "https://picsum.photos/150/150?random=3", createdAt: Date())
        
        self.conversations = [
            Conversation(
                id: UUID(),
                friend: friend1,
                messages: [
                    Message.mock(text: "Ê tí ăn trưa gì nhở?", isSender: false, minutesAgo: 30),
                    Message.mock(text: "Mới gửi mày cái locket ăn bún chả á!", isSender: false, minutesAgo: 29),
                    Message.mock(text: "Ok ngon, đợi tao tí chụp locket lại rồi lưu tiền luôn", isSender: true, minutesAgo: 10)
                ]
            ),
            Conversation(
                id: UUID(),
                friend: friend2,
                messages: [
                    Message.mock(text: "Đã gửi tiền cafe chưa mày?", isSender: false, minutesAgo: 120),
                    Message.mock(text: "Rồi nhé, 45k đúng không?", isSender: true, minutesAgo: 110),
                    Message.mock(text: "Ok thấy rồi nha", isSender: false, minutesAgo: 60)
                ]
            ),
            Conversation(
                id: UUID(),
                friend: friend3,
                messages: [
                    Message.mock(text: "Locket ảnh hoàng hôn đẹp quá kìa!", isSender: false, minutesAgo: 300),
                    Message.mock(text: "Đẹp xuất sắc luôn", isSender: true, minutesAgo: 280)
                ]
            )
        ]
    }
}
