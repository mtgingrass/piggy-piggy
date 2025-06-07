import Foundation

struct Tally: Identifiable, Codable {
    var id: UUID
    var name: String
    var transactions: [Transaction]
    
    var balance: Double {
        transactions.map { $0.amount }.reduce(0, +)
    }
    
    init(id: UUID = UUID(), name: String, transactions: [Transaction] = []) {
        self.id = id
        self.name = name
        self.transactions = transactions
    }
}

struct Transaction: Identifiable, Codable {
    var id: UUID
    var timestamp: Date
    var amount: Double
    var note: String?
    
    init(id: UUID = UUID(), timestamp: Date = Date(), amount: Double, note: String? = nil) {
        self.id = id
        self.timestamp = timestamp
        self.amount = amount
        self.note = note
    }
} 