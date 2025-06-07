import SwiftUI

struct TallyDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TallyViewModel
    let tally: Tally
    @State private var showingAddFunds = false
    @State private var showingSubtractFunds = false
    @State private var showingEditName = false
    @State private var newName = ""
    @State private var amount = ""
    @State private var note = ""
    
    var body: some View {
        List {
            Section {
                HStack {
                    Text(tally.name)
                        .font(.title2)
                    Spacer()
                    Text("$\(tally.balance, specifier: "%.2f")")
                        .font(.title2)
                        .bold()
                }
                
                HStack(spacing: 20) {
                    Button(action: { showingAddFunds = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    Button(action: { showingSubtractFunds = true }) {
                        HStack {
                            Image(systemName: "minus.circle.fill")
                            Text("Subtract")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
            }
            
            Section("Transactions") {
                ForEach(tally.transactions.sorted(by: { $0.timestamp > $1.timestamp })) { transaction in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(transaction.timestamp, style: .date)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            if let note = transaction.note {
                                Text(note)
                                    .font(.subheadline)
                            }
                        }
                        
                        Spacer()
                        
                        Text("$\(transaction.amount, specifier: "%.2f")")
                            .foregroundColor(transaction.amount >= 0 ? .green : .red)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit Name") {
                    newName = tally.name
                    showingEditName = true
                }
            }
        }
        .alert("Edit Name", isPresented: $showingEditName) {
            TextField("Name", text: $newName)
            Button("Cancel", role: .cancel) { }
            Button("Save") {
                viewModel.updateTallyName(tally.id, newName: newName)
            }
        }
        .alert("Add Funds", isPresented: $showingAddFunds) {
            TextField("Amount", text: $amount)
                .keyboardType(.decimalPad)
            TextField("Note (optional)", text: $note)
            Button("Cancel", role: .cancel) {
                amount = ""
                note = ""
            }
            Button("Add") {
                if let amount = Double(amount) {
                    viewModel.addTransaction(to: tally.id, amount: amount, note: note.isEmpty ? nil : note)
                }
                amount = ""
                note = ""
            }
        }
        .alert("Subtract Funds", isPresented: $showingSubtractFunds) {
            TextField("Amount", text: $amount)
                .keyboardType(.decimalPad)
            TextField("Note (optional)", text: $note)
            Button("Cancel", role: .cancel) {
                amount = ""
                note = ""
            }
            Button("Subtract") {
                if let amount = Double(amount) {
                    viewModel.addTransaction(to: tally.id, amount: -amount, note: note.isEmpty ? nil : note)
                }
                amount = ""
                note = ""
            }
        }
    }
}

#Preview {
    NavigationView {
        TallyDetailView(
            viewModel: TallyViewModel(),
            tally: Tally(
                name: "Kai",
                transactions: [
                    Transaction(amount: 100),
                    Transaction(amount: -20, note: "Toy store"),
                    Transaction(amount: 50, note: "Birthday gift")
                ]
            )
        )
    }
} 