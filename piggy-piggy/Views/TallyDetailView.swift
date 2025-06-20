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
    // Allowance UI state
    @State private var showingAllowanceForm = false
    @State private var allowanceAmount = ""
    @State private var allowanceDay = 0
    let weekdays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    
    // Get the current tally from the ViewModel
    private var currentTally: Tally {
        viewModel.tallies.first { $0.id == tally.id } ?? tally
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Balance card
            VStack(spacing: 8) {
                Text("Current Balance")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Text("$\(currentTally.balance, specifier: "%.2f")")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(currentTally.balance >= 0 ? .green : .red)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
            
            // Allowance Section
            Section {
                if showingAllowanceForm {
                    VStack(spacing: 12) {
                        HStack {
                            Text("Weekly Amount:")
                            TextField("Amount", text: $allowanceAmount)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        HStack {
                            Text("Payment Day:")
                            Picker("Day of Week", selection: $allowanceDay) {
                                ForEach(0..<7) { index in
                                    Text(weekdays[index]).tag(index)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        
                        // Buttons
                        VStack(spacing: 8) {
                            Button("Save") {
                                if let amount = Double(allowanceAmount), amount > 0 {
                                    viewModel.updateAllowanceSettings(
                                        for: currentTally.id,
                                        weeklyAmount: amount,
                                        startDay: allowanceDay
                                    )
                                    showingAllowanceForm = false
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(allowanceAmount.isEmpty || Double(allowanceAmount) == nil || Double(allowanceAmount) == 0)
                            
                            Button("Cancel") {
                                showingAllowanceForm = false
                            }
                            .buttonStyle(.bordered)
                            
                            if currentTally.weeklyAllowance != nil {
                                Button(role: .destructive) {
                                    viewModel.updateAllowanceSettings(
                                        for: currentTally.id,
                                        weeklyAmount: nil,
                                        startDay: nil
                                    )
                                    showingAllowanceForm = false
                                } label: {
                                    Text("Remove Allowance")
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                    }
                    .padding()
                } else if let amount = currentTally.weeklyAllowance, let day = currentTally.allowanceStartDay {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("$\(amount, specifier: "%.2f") every \(weekdays[day])")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Button {
                            allowanceAmount = String(amount)
                            allowanceDay = day
                            showingAllowanceForm = true
                        } label: {
                            Image(systemName: "pencil.circle")
                                .foregroundColor(.accentColor)
                        }
                    }
                    .padding(.vertical, 4)
                } else {
                    Button("Set Weekly Allowance") {
                        allowanceAmount = ""
                        allowanceDay = 0
                        showingAllowanceForm = true
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
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
                ForEach(currentTally.transactions.sorted(by: { $0.timestamp > $1.timestamp })) { transaction in
                    TransactionRow(transaction: transaction)
                }
            }
            .listStyle(PlainListStyle())
        }
        .padding()
        .navigationTitle(currentTally.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit Name") {
                    newName = currentTally.name
                    showingEditName = true
                }
            }
        }
        .alert("Edit Name", isPresented: $showingEditName) {
            TextField("Name", text: $newName)
            Button("Cancel", role: .cancel) { }
            Button("Save") {
                viewModel.updateTallyName(currentTally.id, newName: newName)
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            TransactionSheet(
                title: "Add Funds",
                isAdd: true,
                isPresented: $showingAddSheet
            ) { amount, note in
                viewModel.addTransaction(to: currentTally.id, amount: amount, note: note)
            }
        }
        .sheet(isPresented: $showingSubtractSheet) {
            TransactionSheet(
                title: "Subtract Funds",
                isAdd: false,
                isPresented: $showingSubtractSheet
            ) { amount, note in
                viewModel.addTransaction(to: currentTally.id, amount: -amount, note: note)
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

struct TallyDetailView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                TallyDetailView(
                    viewModel: TallyViewModel(),
                    tally: Tally(
                        name: "Kai",
                        transactions: [
                            Transaction(amount: 100),
                            Transaction(amount: -20, note: "Toy store")
                        ]
                    )
                )
            }
            .previewDisplayName("No Allowance")
            
            NavigationView {
                TallyDetailView(
                    viewModel: TallyViewModel(),
                    tally: Tally(
                        name: "Freya",
                        transactions: [
                            Transaction(amount: 50),
                            Transaction(amount: -10, note: "Candy")
                        ],
                        weeklyAllowance: 20,
                        allowanceStartDay: 1,  // Monday
                        lastAllowanceDate: Date()
                    )
                )
            }
            .previewDisplayName("With Allowance")
            
            NavigationView {
                TallyDetailView(
                    viewModel: TallyViewModel(),
                    tally: Tally(
                        name: "Freya",
                        transactions: [
                            Transaction(amount: 50),
                            Transaction(amount: -10, note: "Candy")
                        ],
                        weeklyAllowance: 20,
                        allowanceStartDay: 1,
                        lastAllowanceDate: Date()
                    )
                )
            }
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
            
            NavigationView {
                TallyDetailView(
                    viewModel: TallyViewModel(),
                    tally: Tally(
                        name: "New Tally",
                        transactions: []
                    )
                )
            }
            .previewDisplayName("Empty State")
        }
    }
}

