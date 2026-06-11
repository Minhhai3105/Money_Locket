import Foundation

enum TransactionType: String, Codable, CaseIterable {
    case income
    case expense
    case social_only = "social_only"
}

struct TransactionCategory: Identifiable, Codable, Hashable {
    var id: String { name }
    let name: String
    let iconName: String
    
    static let dining = TransactionCategory(name: "Dining", iconName: "fork.knife")
    static let shopping = TransactionCategory(name: "Shopping", iconName: "bag.fill")
    static let transport = TransactionCategory(name: "Transport", iconName: "car.fill")
    static let friends = TransactionCategory(name: "Friends", iconName: "person.2.fill")
    static let others = TransactionCategory(name: "Others", iconName: "ellipsis.circle.fill")
    
    static let all: [TransactionCategory] = [.dining, .shopping, .transport, .friends, .others]
}

struct Transaction: Identifiable, Codable, Hashable {
    let id: UUID
    let userId: UUID
    let photoUrl: String?
    let amount: Double
    let type: TransactionType
    let category: String
    let notes: String?
    let latitude: Double?
    let longitude: Double?
    let createdAt: Date
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }
    
    static func mock(amount: Double, type: TransactionType, category: String, notes: String? = nil, hoursAgo: Int = 0) -> Transaction {
        Transaction(
            id: UUID(),
            userId: UUID(),
            photoUrl: "https://picsum.photos/300/300?random=\(Int.random(in: 1...1000))",
            amount: amount,
            type: type,
            category: category,
            notes: notes,
            latitude: 10.762,
            longitude: 106.660,
            createdAt: Calendar.current.date(byAdding: .hour, value: -hoursAgo, to: Date()) ?? Date()
        )
    }
}
