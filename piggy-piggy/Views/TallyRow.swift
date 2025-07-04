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
                    if let amountValue = Double(amount), amountValue > 0, amountValue.isFinite, amountValue <= 99999 {
                        let cleanNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
                        onSave(amountValue, cleanNote.isEmpty ? nil : cleanNote)
                    }
                    isPresented = false
                }
                .disabled(Double(amount) == nil || Double(amount) ?? 0 <= 0 || Double(amount) ?? 0 > 99999)
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
    
    private let weekdays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    
    var body: some View {
        VStack(spacing: 12) {
            // Navigation area
            NavigationLink(destination: TallyDetailView(viewModel: viewModel, tally: tally)) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(tally.name)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        Text("$\(tally.balance, specifier: "%.2f")")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: tally.balance >= 0 ? [.green, .mint] : [.red, .orange],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground))
                                    .shadow(color: (tally.balance >= 0 ? Color.green : Color.red).opacity(0.2), radius: 4, x: 0, y: 2)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        LinearGradient(
                                            colors: tally.balance >= 0 ? [.green.opacity(0.3), .mint.opacity(0.3)] : [.red.opacity(0.3), .orange.opacity(0.3)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                        
                        // Allowance info
                        if let amount = tally.weeklyAllowance,
                           let day = tally.allowanceStartDay {
                            HStack(spacing: 8) {
                                Text("ALLOWANCE")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        LinearGradient(
                                            colors: [.purple, .blue],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .cornerRadius(8)
                                    .shadow(color: .purple.opacity(0.3), radius: 2, x: 0, y: 1)
                                Text("$\(amount, specifier: "%.2f") every \(weekdays[day])")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    Spacer()
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title2)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .blue.opacity(0.3), radius: 2, x: 0, y: 1)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            
            // Action buttons in a separate container
            HStack(spacing: 16) {
                // Add button
                Button {
                    showingAddSheet = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                        Text("Add")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [.green, .mint],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(color: .green.opacity(0.3), radius: 3, x: 0, y: 2)
                }
                .buttonStyle(BorderlessButtonStyle())
                
                // Subtract button
                Button {
                    showingSubtractSheet = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "minus.circle.fill")
                            .font(.title3)
                        Text("Subtract")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [.red, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(color: .red.opacity(0.3), radius: 3, x: 0, y: 2)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground))
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.4 : 0.1), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [.purple.opacity(0.2), .blue.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
        .padding(.horizontal)
        .padding(.vertical, 8)
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

