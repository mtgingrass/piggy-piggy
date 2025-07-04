import SwiftUI

struct AllowanceSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TallyViewModel
    let tally: Tally
    
    @State private var allowanceAmount: String
    @State private var allowanceDay: Int
    let weekdays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    
    init(viewModel: TallyViewModel, tally: Tally) {
        self.viewModel = viewModel
        self.tally = tally
        // Initialize state with current values if they exist
        _allowanceAmount = State(initialValue: tally.weeklyAllowance.map { String($0) } ?? "")
        _allowanceDay = State(initialValue: tally.allowanceStartDay ?? 0)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header section with gradient background
                VStack(spacing: 16) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 48, weight: .light))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .blue.opacity(0.3), radius: 4, x: 0, y: 2)
                    
                    Text("Allowance Settings")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }
                .padding(.top, 20)
                .padding(.bottom, 30)
                .background(
                    LinearGradient(
                        colors: [Color(.systemBackground), Color(.systemGroupedBackground)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                Form {
                    Section {
                        HStack {
                            Text("Weekly Amount")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                            Spacer()
                            TextField("Amount", text: $allowanceAmount)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                        }
                        .padding(.vertical, 4)
                        
                        Picker("Payment Day", selection: $allowanceDay) {
                            ForEach(0..<7) { index in
                                Text(weekdays[index])
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .tag(index)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding(.vertical, 4)
                    } header: {
                        Label("Configuration", systemImage: "gear")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.secondary)
                    } footer: {
                        Text("The allowance will be automatically added every week on the selected day.")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                    )
                    
                    if tally.weeklyAllowance != nil {
                        Section {
                            Button(role: .destructive) {
                                viewModel.updateAllowanceSettings(
                                    for: tally.id,
                                    weeklyAmount: nil,
                                    startDay: nil
                                )
                                dismiss()
                            } label: {
                                HStack {
                                    Image(systemName: "trash.circle.fill")
                                        .font(.title2)
                                    Text("Remove Allowance")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    Spacer()
                                }
                                .foregroundColor(.white)
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity)
                                .background(
                                    LinearGradient(
                                        colors: [.red, .orange],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(12)
                                .shadow(color: .red.opacity(0.3), radius: 4, x: 0, y: 2)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                        .listRowBackground(Color.clear)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let amount = Double(allowanceAmount), amount > 0, amount.isFinite, amount <= 9999 {
                            viewModel.updateAllowanceSettings(
                                for: tally.id,
                                weeklyAmount: amount,
                                startDay: allowanceDay
                            )
                            dismiss()
                        }
                    }
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .disabled(allowanceAmount.isEmpty || Double(allowanceAmount) == nil || Double(allowanceAmount) ?? 0 <= 0 || Double(allowanceAmount) ?? 0 > 9999)
                }
            }
            .background(
                LinearGradient(
                    colors: [Color(.systemGroupedBackground), Color(.systemBackground)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }
}

struct AllowanceSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        // Preview with no existing allowance
        AllowanceSettingsView(
            viewModel: TallyViewModel(),
            tally: Tally(
                name: "New Tally",
                transactions: []
            )
        )
        .previewDisplayName("New Allowance")
        
        // Preview with existing allowance
        AllowanceSettingsView(
            viewModel: TallyViewModel(),
            tally: Tally(
                name: "Existing Tally",
                transactions: [],
                weeklyAllowance: 20,
                allowanceStartDay: 1,
                lastAllowanceDate: Date()
            )
        )
        .previewDisplayName("Edit Existing")
        
        // Dark mode preview
        AllowanceSettingsView(
            viewModel: TallyViewModel(),
            tally: Tally(
                name: "Dark Mode",
                transactions: [],
                weeklyAllowance: 15,
                allowanceStartDay: 5,
                lastAllowanceDate: Date()
            )
        )
        .preferredColorScheme(.dark)
        .previewDisplayName("Dark Mode")
    }
} 