import Foundation

struct Tally: Identifiable, Codable {
    var id: UUID
    var name: String
    var transactions: [Transaction]
    var weeklyAllowance: Double?
    var allowanceStartDay: Int?  // 0 = Sunday ... 6 = Saturday
    var lastAllowanceDate: Date?
    
    var balance: Double {
        transactions.map { $0.amount }.reduce(0, +)
    }
    
    init(id: UUID = UUID(), name: String, transactions: [Transaction] = [], weeklyAllowance: Double? = nil, allowanceStartDay: Int? = nil, lastAllowanceDate: Date? = nil) {
        self.id = id
        self.name = name
        self.transactions = transactions
        self.weeklyAllowance = weeklyAllowance
        self.allowanceStartDay = allowanceStartDay
        self.lastAllowanceDate = lastAllowanceDate
    }
}

struct Transaction: Identifiable, Codable {
    var id: UUID
    var timestamp: Date
    var amount: Double
    var note: String?
    var isAllowance: Bool
    
    init(id: UUID = UUID(), timestamp: Date = Date(), amount: Double, note: String? = nil, isAllowance: Bool = false) {
        self.id = id
        self.timestamp = timestamp
        self.amount = amount
        self.note = note
        self.isAllowance = isAllowance
    }
} 