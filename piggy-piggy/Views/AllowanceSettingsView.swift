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
            Form {
                Section {
                    HStack {
                        Text("Weekly Amount")
                        Spacer()
                        TextField("Amount", text: $allowanceAmount)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    Picker("Payment Day", selection: $allowanceDay) {
                        ForEach(0..<7) { index in
                            Text(weekdays[index]).tag(index)
                        }
                    }
                } header: {
                    Text("Allowance Settings")
                } footer: {
                    Text("The allowance will be automatically added every week on the selected day.")
                }
                
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
                                Spacer()
                                Text("Remove Allowance")
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Allowance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let amount = Double(allowanceAmount), amount > 0 {
                            viewModel.updateAllowanceSettings(
                                for: tally.id,
                                weeklyAmount: amount,
                                startDay: allowanceDay
                            )
                            dismiss()
                        }
                    }
                    .disabled(allowanceAmount.isEmpty || Double(allowanceAmount) == nil || Double(allowanceAmount) == 0)
                }
            }
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