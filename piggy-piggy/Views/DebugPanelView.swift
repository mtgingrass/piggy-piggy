import SwiftUI

struct DebugPanelView: View {
    @ObservedObject var viewModel: TallyViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var timeTravelAmount = 1
    @State private var timeTravelUnit = TimeUnit.week
    @State private var simulatedDate = Date()
    
    enum TimeUnit: String, CaseIterable {
        case day = "Day"
        case week = "Week"
    }
    
    private let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"  // Full weekday name
        return formatter
    }()
    
    var body: some View {
        Form {
            // Time Travel Section
            Section {
                HStack {
                    Text("Current Date")
                    Spacer()
                    Text(simulatedDate, style: .date)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Day of Week")
                    Spacer()
                    Text(weekdayFormatter.string(from: simulatedDate))
                        .foregroundColor(.secondary)
                }
                
                Stepper {
                    HStack {
                        Text("Travel")
                        Text("\(timeTravelAmount)")
                            .foregroundColor(.accentColor)
                        Text(timeTravelUnit.rawValue.lowercased() + (timeTravelAmount == 1 ? "" : "s"))
                    }
                } onIncrement: {
                    if timeTravelAmount < 30 {
                        timeTravelAmount += 1
                    }
                } onDecrement: {
                    if timeTravelAmount > 1 {
                        timeTravelAmount -= 1
                    }
                }
                
                Picker("Unit", selection: $timeTravelUnit) {
                    ForEach(TimeUnit.allCases, id: \.self) { unit in
                        Text(unit.rawValue + "s").tag(unit)
                    }
                }
                .pickerStyle(.segmented)
                
                Button {
                    switch timeTravelUnit {
                    case .day:
                        viewModel.simulateTimeTravel(days: timeTravelAmount)
                        simulatedDate = Calendar.current.date(byAdding: .day, value: timeTravelAmount, to: simulatedDate) ?? simulatedDate
                    case .week:
                        viewModel.simulateTimeTravel(weeks: timeTravelAmount)
                        simulatedDate = Calendar.current.date(byAdding: .weekOfYear, value: timeTravelAmount, to: simulatedDate) ?? simulatedDate
                    }
                } label: {
                    Label("Time Travel", systemImage: "clock.arrow.circlepath")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            } header: {
                Text("Time Travel")
            } footer: {
                Text("Simulate the passage of time to test allowance payments.")
            }
            
            // Debug Tally Section
            Section {
                Button {
                    viewModel.createDebugTally()
                } label: {
                    Label("Create Debug Tally", systemImage: "plus.circle.fill")
                }
                
                if let debugTally = viewModel.tallies.first(where: { $0.name == "Debug Child" }) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Balance")
                            Spacer()
                            Text("$\(debugTally.balance, specifier: "%.2f")")
                                .foregroundColor(debugTally.balance >= 0 ? .green : .red)
                        }
                        
                        if let amount = debugTally.weeklyAllowance {
                            HStack {
                                Text("Weekly Allowance")
                                Spacer()
                                Text("$\(amount, specifier: "%.2f")")
                                    .foregroundColor(.green)
                            }
                        }
                        
                        if let date = debugTally.lastAllowanceDate {
                            HStack {
                                Text("Last Payment")
                                Spacer()
                                Text(date, style: .date)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Button(role: .destructive) {
                            viewModel.clearDebugData()
                        } label: {
                            Label("Clear Debug Data", systemImage: "trash.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                }
            } header: {
                Text("Debug Tally")
            } footer: {
                Text("Create a test tally with predefined settings for debugging.")
            }
        }
        .navigationTitle("Debug Panel")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}

struct DebugPanelView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                DebugPanelView(viewModel: TallyViewModel())
            }
            .previewDisplayName("Default")
            
            NavigationView {
                let viewModel = TallyViewModel()
                viewModel.createDebugTally()
                return DebugPanelView(viewModel: viewModel)
            }
            .previewDisplayName("With Debug Tally")
            
            NavigationView {
                DebugPanelView(viewModel: TallyViewModel())
            }
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
    }
} 
