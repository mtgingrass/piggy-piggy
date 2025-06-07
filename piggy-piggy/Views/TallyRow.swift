import SwiftUI

struct TransactionSheet: View {
    let title: String
    let isAdd: Bool
    @Binding var isPresented: Bool
    let onSave: (Double, String?) -> Void
    
    @State private var amount = ""
    @State private var note = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                    TextField("Note (optional)", text: $note)
                }
            }
            .navigationTitle(title)
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button(isAdd ? "Add" : "Subtract") {
                    if let amountValue = Double(amount) {
                        onSave(amountValue, note.isEmpty ? nil : note)
                    }
                    isPresented = false
                }
            )
        }
    }
}

struct TallyRow: View {
    @ObservedObject var viewModel: TallyViewModel
    let tally: Tally
    
    @State private var showingAddSheet = false
    @State private var showingSubtractSheet = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Navigation area
            NavigationLink(destination: TallyDetailView(viewModel: viewModel, tally: tally)) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(tally.name)
                            .font(.headline)
                        Text("$\(tally.balance, specifier: "%.2f")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            
            // Action buttons in a separate container
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
                    .padding(.vertical, 8)
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
                    .padding(.vertical, 8)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
        }
        .padding(.vertical, 8)
        // Sheets in separate modifiers
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

#Preview("Default State") {
    NavigationView {
        TallyRow(
            viewModel: TallyViewModel(),
            tally: Tally(
                name: "Kai",
                transactions: [
                    Transaction(amount: 100),
                    Transaction(amount: -20, note: "Toy store")
                ]
            )
        )
        .padding()
    }
    .previewLayout(.sizeThatFits)
}

