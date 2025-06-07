import SwiftUI

struct TallyDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TallyViewModel
    let tally: Tally
    @State private var showingAddSheet = false
    @State private var showingSubtractSheet = false
    @State private var showingEditName = false
    @State private var newName = ""
    @State private var amount = ""
    @State private var note = ""
    
    var body: some View {
        VStack(spacing: 16) {
            // Balance card
            VStack(spacing: 8) {
                Text("Current Balance")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Text("$\(tally.balance, specifier: "%.2f")")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(tally.balance >= 0 ? .green : .red)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
            
            // Action buttons
            HStack(spacing: 12) {
                // Add button
                Button {
                    showingAddSheet = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .buttonStyle(BorderlessButtonStyle())
                
                // Subtract button
                Button {
                    showingSubtractSheet = true
                } label: {
                    HStack {
                        Image(systemName: "minus.circle.fill")
                        Text("Subtract")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            .padding(.horizontal)
            
            // Transactions list
            List {
                ForEach(tally.transactions.sorted(by: { $0.timestamp > $1.timestamp })) { transaction in
                    TransactionRow(transaction: transaction)
                }
            }
            .listStyle(PlainListStyle())
        }
        .padding()
        .navigationTitle(tally.name)
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
        .sheet(isPresented: $showingAddSheet) {
            TransactionSheet(
                title: "Add Funds",
                isAdd: true,
                isPresented: $showingAddSheet
            ) { amount, note in
                viewModel.addTransaction(to: tally.id, amount: amount, note: note)
            }
        }
        .sheet(isPresented: $showingSubtractSheet) {
            TransactionSheet(
                title: "Subtract Funds",
                isAdd: false,
                isPresented: $showingSubtractSheet
            ) { amount, note in
                viewModel.addTransaction(to: tally.id, amount: -amount, note: note)
            }
        }
    }
}

struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
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
        .padding(.vertical, 4)
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