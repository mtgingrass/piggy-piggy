import Foundation
import SwiftUI

@MainActor
class TallyViewModel: ObservableObject {
    @Published var tallies: [Tally] = []
    private let saveKey = "savedTallies"
    
    init() {
        loadTallies()
        if tallies.isEmpty {
            // Add default tallies
            tallies = [
                Tally(name: "Kai", transactions: [Transaction(amount: 100)]),
                Tally(name: "Freya", transactions: [Transaction(amount: 100)])
            ]
            saveTallies()
        }
    }
    
    func addTally(name: String) {
        let newTally = Tally(name: name)
        tallies.append(newTally)
        saveTallies()
    }
    
    func deleteTally(at indexSet: IndexSet) {
        tallies.remove(atOffsets: indexSet)
        saveTallies()
    }
    
    func addTransaction(to tallyId: UUID, amount: Double, note: String? = nil) {
        guard let index = tallies.firstIndex(where: { $0.id == tallyId }) else { return }
        let transaction = Transaction(amount: amount, note: note)
        tallies[index].transactions.append(transaction)
        saveTallies()
    }
    
    func updateTallyName(_ tallyId: UUID, newName: String) {
        guard let index = tallies.firstIndex(where: { $0.id == tallyId }) else { return }
        tallies[index].name = newName
        saveTallies()
    }
    
    private func saveTallies() {
        if let encoded = try? JSONEncoder().encode(tallies) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadTallies() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Tally].self, from: data) {
            tallies = decoded
        }
    }
} 