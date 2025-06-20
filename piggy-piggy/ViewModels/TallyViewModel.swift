import Foundation
import SwiftUI

@MainActor
class TallyViewModel: ObservableObject {
    @Published var tallies: [Tally] = []
    private let saveKey = "savedTallies"
    
    // Debug mode - set to false for production
    private let isDebugMode = true
    
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
        checkAndApplyMissedAllowances()
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
            checkAndApplyMissedAllowances()
        }
    }
    
    func updateAllowanceSettings(for tallyId: UUID, weeklyAmount: Double?, startDay: Int?) {
        guard let index = tallies.firstIndex(where: { $0.id == tallyId }) else { return }
        tallies[index].weeklyAllowance = weeklyAmount
        tallies[index].allowanceStartDay = startDay
        if weeklyAmount != nil && startDay != nil {
            tallies[index].lastAllowanceDate = Date()
        } else {
            tallies[index].lastAllowanceDate = nil
        }
        saveTallies()
    }
    
    func checkAndApplyMissedAllowances() {
        let calendar = Calendar.current
        let now = Date()
        
        for (index, tally) in tallies.enumerated() {
            // Skip if allowance is not set up
            guard let weeklyAmount = tally.weeklyAllowance,
                  let startDay = tally.allowanceStartDay,
                  let lastAllowance = tally.lastAllowanceDate else {
                continue
            }
            
            // Get the number of weeks between lastAllowance and now
            let components = calendar.dateComponents([.weekOfYear], from: lastAllowance, to: now)
            guard let weeksElapsed = components.weekOfYear, weeksElapsed > 0 else {
                continue
            }
            
            print("Processing allowance for \(tally.name):")
            print("- Weeks elapsed: \(weeksElapsed)")
            print("- Weekly amount: $\(weeklyAmount)")
            print("- Last allowance: \(lastAllowance)")
            
            // Create a transaction for each missed week
            var currentDate = lastAllowance
            for weekNum in 1...weeksElapsed {
                // Move to next week
                currentDate = calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate) ?? currentDate
                
                // Add the transaction
                let transaction = Transaction(
                    timestamp: currentDate,
                    amount: weeklyAmount,
                    note: "Weekly Allowance"
                )
                tallies[index].transactions.append(transaction)
                
                print("- Added week \(weekNum) allowance: $\(weeklyAmount) on \(currentDate)")
            }
            
            // Update the last allowance date to the most recent payment
            tallies[index].lastAllowanceDate = currentDate
            print("- Updated last allowance date to: \(currentDate)")
            print("- New balance: $\(tallies[index].balance)")
        }
        
        // Save changes if any allowances were applied
        saveTallies()
    }
    
    // Test method to verify allowance functionality
    func testAllowanceProcessing() {
        // Create a tally with allowance set 3 weeks ago
        let calendar = Calendar.current
        let threeWeeksAgo = calendar.date(byAdding: .weekOfYear, value: -3, to: Date())!
        
        let testTally = Tally(
            name: "Test Child",
            transactions: [Transaction(amount: 100, note: "Initial deposit")],
            weeklyAllowance: 10.0,
            allowanceStartDay: 5, // Friday
            lastAllowanceDate: threeWeeksAgo
        )
        
        // Add test tally
        tallies.append(testTally)
        print("\nInitial state:")
        print("- Balance: $\(testTally.balance)")
        print("- Last allowance: \(threeWeeksAgo)")
        
        // Process allowances
        print("\nProcessing allowances...")
        checkAndApplyMissedAllowances()
        
        // Verify results
        if let updatedTally = tallies.first(where: { $0.id == testTally.id }) {
            print("\nFinal state:")
            print("- New balance: $\(updatedTally.balance)")
            print("- Expected balance: $\(100 + (10 * 3))") // Initial + (weekly * 3)
            print("- Transaction count: \(updatedTally.transactions.count)")
            print("- Allowance transactions:")
            updatedTally.transactions
                .filter { $0.note == "Weekly Allowance" }
                .forEach { print("  • \($0.amount) on \($0.timestamp)") }
            
            // Test toggling allowance off
            print("\nTesting allowance toggle off...")
            updateAllowanceSettings(for: updatedTally.id, weeklyAmount: nil, startDay: nil)
            
            if let toggledTally = tallies.first(where: { $0.id == testTally.id }) {
                print("- Allowance disabled:")
                print("  • Weekly amount: \(toggledTally.weeklyAllowance == nil ? "nil" : "$\(toggledTally.weeklyAllowance!)")")
                print("  • Start day: \(toggledTally.allowanceStartDay == nil ? "nil" : "\(toggledTally.allowanceStartDay!)")")
                print("  • Last date: \(toggledTally.lastAllowanceDate == nil ? "nil" : "\(toggledTally.lastAllowanceDate!)")")
                print("  • Transactions preserved: \(toggledTally.transactions.count)")
            }
        }
    }
    
    // MARK: - Debug Methods (only available in debug mode)
    
    func simulateTimeTravel(weeks: Int) {
        guard isDebugMode else { return }
        
        print("\n=== TIME TRAVEL SIMULATION ===")
        print("Traveling \(weeks) weeks into the future...")
        
        // Create a fake "current date" that's weeks in the future
        let futureDate = Calendar.current.date(byAdding: .weekOfYear, value: weeks, to: Date())!
        
        // Process allowances with the future date
        let calendar = Calendar.current
        
        for (index, tally) in tallies.enumerated() {
            guard let weeklyAmount = tally.weeklyAllowance,
                  let startDay = tally.allowanceStartDay,
                  let lastAllowance = tally.lastAllowanceDate else {
                continue
            }
            
            let components = calendar.dateComponents([.weekOfYear], from: lastAllowance, to: futureDate)
            guard let weeksElapsed = components.weekOfYear, weeksElapsed > 0 else {
                continue
            }
            
            print("\nProcessing \(tally.name)'s allowance:")
            print("- Current balance: $\(tally.balance)")
            print("- Weeks to simulate: \(weeksElapsed)")
            print("- Weekly amount: $\(weeklyAmount)")
            
            var currentDate = lastAllowance
            for weekNum in 1...weeksElapsed {
                currentDate = calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate) ?? currentDate
                
                let transaction = Transaction(
                    timestamp: currentDate,
                    amount: weeklyAmount,
                    note: "Weekly Allowance (Simulated)"
                )
                tallies[index].transactions.append(transaction)
                
                print("  • Week \(weekNum): +$\(weeklyAmount) on \(currentDate)")
            }
            
            tallies[index].lastAllowanceDate = currentDate
            print("- New balance: $\(tallies[index].balance)")
        }
        
        saveTallies()
        print("=== SIMULATION COMPLETE ===\n")
    }
    
    func simulateTimeTravel(days: Int) {
        guard isDebugMode else { return }
        
        print("\n=== TIME TRAVEL SIMULATION ===")
        print("Traveling \(days) days into the future...")
        
        // Create a fake "current date" that's days in the future
        let futureDate = Calendar.current.date(byAdding: .day, value: days, to: Date())!
        
        // Process allowances with the future date
        let calendar = Calendar.current
        
        for (index, tally) in tallies.enumerated() {
            guard let weeklyAmount = tally.weeklyAllowance,
                  let startDay = tally.allowanceStartDay,
                  let lastAllowance = tally.lastAllowanceDate else {
                continue
            }
            
            let components = calendar.dateComponents([.weekOfYear], from: lastAllowance, to: futureDate)
            guard let weeksElapsed = components.weekOfYear, weeksElapsed > 0 else {
                continue
            }
            
            print("\nProcessing \(tally.name)'s allowance:")
            print("- Current balance: $\(tally.balance)")
            print("- Days traveled: \(days)")
            print("- Weeks to simulate: \(weeksElapsed)")
            print("- Weekly amount: $\(weeklyAmount)")
            
            var currentDate = lastAllowance
            for weekNum in 1...weeksElapsed {
                currentDate = calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate) ?? currentDate
                
                let transaction = Transaction(
                    timestamp: currentDate,
                    amount: weeklyAmount,
                    note: "Weekly Allowance (Simulated)"
                )
                tallies[index].transactions.append(transaction)
                
                print("  • Week \(weekNum): +$\(weeklyAmount) on \(currentDate)")
            }
            
            tallies[index].lastAllowanceDate = currentDate
            print("- New balance: $\(tallies[index].balance)")
        }
        
        saveTallies()
        print("=== SIMULATION COMPLETE ===\n")
    }
    
    func createDebugTally() {
        guard isDebugMode else { return }
        
        let calendar = Calendar.current
        let twoWeeksAgo = calendar.date(byAdding: .weekOfYear, value: -2, to: Date())!
        
        let debugTally = Tally(
            name: "Debug Child",
            transactions: [
                Transaction(amount: 50, note: "Initial deposit"),
                Transaction(amount: -5, note: "Candy store")
            ],
            weeklyAllowance: 15.0,
            allowanceStartDay: 3, // Wednesday
            lastAllowanceDate: twoWeeksAgo
        )
        
        tallies.append(debugTally)
        saveTallies()
        
        print("Created debug tally:")
        print("- Name: \(debugTally.name)")
        print("- Initial balance: $\(debugTally.balance)")
        print("- Weekly allowance: $\(debugTally.weeklyAllowance ?? 0)")
        print("- Payment day: \(weekdays[debugTally.allowanceStartDay ?? 0])")
        print("- Last payment: \(twoWeeksAgo)")
    }
    
    func clearDebugData() {
        guard isDebugMode else { return }
        
        tallies.removeAll { $0.name == "Debug Child" || $0.name == "Test Child" }
        saveTallies()
        print("Cleared debug data")
    }
    
    private let weekdays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
} 