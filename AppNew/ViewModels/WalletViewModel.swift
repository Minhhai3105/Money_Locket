import SwiftUI
import Combine

struct CategoryAggregate: Identifiable, Hashable {
    var id: String { category }
    let category: String
    let amount: Double
    let color: Color
}

class WalletViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    
    // Aggregated stats
    @Published var currentBalance: Double = 0.0
    @Published var monthlyIncome: Double = 0.0
    @Published var monthlyExpense: Double = 0.0
    @Published var chartData: [CategoryAggregate] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadMockData()
        calculateSummary()
    }
    
    func addTransaction(amount: Double, category: String, notes: String?, type: TransactionType, photoUrl: String? = nil) {
        let newTx = Transaction(
            id: UUID(),
            userId: UUID(),
            photoUrl: photoUrl ?? "https://picsum.photos/300/300?random=\(Int.random(in: 1...1000))",
            amount: amount,
            type: type,
            category: category,
            notes: notes,
            latitude: nil,
            longitude: nil,
            createdAt: Date()
        )
        
        DispatchQueue.main.async {
            self.transactions.insert(newTx, at: 0)
            self.calculateSummary()
        }
    }
    
    func calculateSummary() {
        var balance = 0.0
        var income = 0.0
        var expense = 0.0
        var expenseByCategory: [String: Double] = [:]
        
        for tx in transactions {
            if tx.type == .income {
                balance += tx.amount
                income += tx.amount
            } else if tx.type == .expense {
                balance -= tx.amount
                expense += tx.amount
                expenseByCategory[tx.category, default: 0.0] += tx.amount
            }
        }
        
        // Colors mapping
        let colorsMap: [String: Color] = [
            "Dining": .orange,
            "Shopping": .blue,
            "Transport": .purple,
            "Friends": .pink,
            "Others": .gray
        ]
        
        let aggregates = expenseByCategory.map { (cat, val) in
            CategoryAggregate(category: cat, amount: val, color: colorsMap[cat] ?? .blue)
        }.sorted { $0.amount > $1.amount }
        
        self.currentBalance = balance
        self.monthlyIncome = income
        self.monthlyExpense = expense
        self.chartData = aggregates
    }
    
    private func loadMockData() {
        self.transactions = [
            Transaction.mock(amount: 150000, type: .expense, category: "Dining", notes: "Ăn trưa lẩu Tokbokki", hoursAgo: 2),
            Transaction.mock(amount: 450000, type: .expense, category: "Shopping", notes: "Mua áo phông thun", hoursAgo: 24),
            Transaction.mock(amount: 5000000, type: .income, category: "Others", notes: "Lương part-time", hoursAgo: 48),
            Transaction.mock(amount: 45000, type: .expense, category: "Transport", notes: "Grab đi học", hoursAgo: 72),
            Transaction.mock(amount: 120000, type: .expense, category: "Friends", notes: "Cafe cùng hội bạn", hoursAgo: 96),
            Transaction.mock(amount: 0, type: .social_only, category: "Others", notes: "Cảnh đẹp chiều nay", hoursAgo: 120)
        ]
    }
    
    // Formatting Helpers
    var formattedBalance: String {
        formatCurrency(currentBalance) + " ₫"
    }
    
    var formattedIncome: String {
        "+" + formatCurrency(monthlyIncome) + " ₫"
    }
    
    var formattedExpense: String {
        "-" + formatCurrency(monthlyExpense) + " ₫"
    }
    
    func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }
}
