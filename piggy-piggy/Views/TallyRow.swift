import SwiftUI

struct TransactionSheet: View {
    let title: String
    let isAdd: Bool
    @Binding var isPresented: Bool
    let onSave: (Double, String?) -> Void
    
    @State private var amount = ""
    @State private var note = ""
    @FocusState private var isAmountFocused: Bool
    
    private let quickAmounts = [1.0, 5.0, 10.0, 20.0]
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                        .focused($isAmountFocused)
                    
                    // Quick amount buttons
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(quickAmounts, id: \.self) { value in
                                Button {
                                    amount = String(format: "%.2f", value)
                                } label: {
                                    Text("$\(value, specifier: "%.0f")")
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    
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
            .onAppear {
                // Focus the amount field when the sheet appears
                isAmountFocused = true
            }
        }
    }
}

struct TallyRow: View {
    @ObservedObject var viewModel: TallyViewModel
    let tally: Tally
    @Environment(\.colorScheme) var colorScheme
    
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
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 2, x: 0, y: 1)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(colorScheme == .dark ? Color(.systemGray4) : Color(.systemGray5), lineWidth: 1)
        )
        .padding(.horizontal)
        .padding(.vertical, 4)
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
        ScrollView {
            VStack(spacing: 8) {
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
                
                TallyRow(
                    viewModel: TallyViewModel(),
                    tally: Tally(
                        name: "Freya",
                        transactions: [
                            Transaction(amount: 50),
                            Transaction(amount: -10, note: "Candy")
                        ]
                    )
                )
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
    }
    .previewLayout(.sizeThatFits)
}

#Preview("Dark Mode") {
    NavigationView {
        ScrollView {
            VStack(spacing: 8) {
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
                
                TallyRow(
                    viewModel: TallyViewModel(),
                    tally: Tally(
                        name: "Freya",
                        transactions: [
                            Transaction(amount: 50),
                            Transaction(amount: -10, note: "Candy")
                        ]
                    )
                )
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
    }
    .preferredColorScheme(.dark)
    .previewLayout(.sizeThatFits)
}

