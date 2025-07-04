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
            VStack(spacing: 12) {
                Text("Current Balance")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)
                Text("$\(currentTally.balance, specifier: "%.2f")")
                    .font(.system(size: 56, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: currentTally.balance >= 0 ? [.green, .mint] : [.red, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: (currentTally.balance >= 0 ? Color.green : Color.red).opacity(0.3), radius: 4, x: 0, y: 2)
            }
            .frame(maxWidth: .infinity)
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [.purple.opacity(0.3), .blue.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
            
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
                        HStack(spacing: 8) {
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
                                    Text("Remove")
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                    }
                    .padding(20)
                } else if let amount = currentTally.weeklyAllowance, let day = currentTally.allowanceStartDay {
                    HStack {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.title2)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.green, .mint],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        Text("$\(amount, specifier: "%.2f") every \(weekdays[day])")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.primary)
                        Spacer()
                        Button {
                            showingAllowanceForm = true
                        } label: {
                            Image(systemName: "pencil.circle.fill")
                                .font(.title2)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                    }
                    .padding(.vertical, 8)
                } else {
                    Button {
                        showingAllowanceForm = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                            Text("Set Weekly Allowance")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: .blue.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [.purple.opacity(0.2), .blue.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .sheet(isPresented: $showingAllowanceForm) {
                AllowanceSettingsView(viewModel: viewModel, tally: currentTally)
            }
            
            // Action buttons
            HStack(spacing: 16) {
                // Add button
                Button {
                    showingAddSheet = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                        Text("Add")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [.green, .mint],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .shadow(color: .green.opacity(0.3), radius: 4, x: 0, y: 2)
                }
                .buttonStyle(BorderlessButtonStyle())
                
                // Subtract button
                Button {
                    showingSubtractSheet = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "minus.circle.fill")
                            .font(.title2)
                        Text("Subtract")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [.red, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .shadow(color: .red.opacity(0.3), radius: 4, x: 0, y: 2)
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
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color(.systemGroupedBackground), Color(.systemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .navigationTitle(currentTally.name)
        .navigationBarTitleDisplayMode(.large)
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

