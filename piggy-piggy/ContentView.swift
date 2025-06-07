//
//  ContentView.swift
//  piggy-piggy
//
//  Created by Mark Gingrass on 6/6/25.
//

import SwiftUI

class ThemeManager: ObservableObject {
    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        }
    }
    
    init() {
        self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
    }
}

struct ContentView: View {
    @StateObject private var viewModel = TallyViewModel()
    @StateObject private var themeManager = ThemeManager()
    @State private var showingAddTally = false
    @State private var newTallyName = ""
    @State private var tallyToDelete: Tally?
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.tallies) { tally in
                    TallyRow(viewModel: viewModel, tally: tally)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }
                .onDelete { indexSet in
                    if let index = indexSet.first {
                        tallyToDelete = viewModel.tallies[index]
                        showingDeleteConfirmation = true
                    }
                }
            }
            .listStyle(PlainListStyle())
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Piggy Piggy")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingAddTally = true }) {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { themeManager.isDarkMode.toggle() }) {
                        Image(systemName: themeManager.isDarkMode ? "sun.max.fill" : "moon.fill")
                    }
                }
            }
            .alert("Add New Tally", isPresented: $showingAddTally) {
                TextField("Name", text: $newTallyName)
                Button("Cancel", role: .cancel) {
                    newTallyName = ""
                }
                Button("Add") {
                    viewModel.addTally(name: newTallyName)
                    newTallyName = ""
                }
            }
            .alert("Delete Tally", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) {
                    tallyToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let tally = tallyToDelete,
                       let index = viewModel.tallies.firstIndex(where: { $0.id == tally.id }) {
                        viewModel.deleteTally(at: IndexSet(integer: index))
                    }
                    tallyToDelete = nil
                }
            } message: {
                if let tally = tallyToDelete {
                    Text("Are you sure you want to delete \(tally.name)'s tally? This cannot be undone.")
                }
            }
        }
        .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
    }
}

#Preview("Default State") {
    ContentView()
}

#Preview("With Transactions") {
    let viewModel = TallyViewModel()
    viewModel.tallies = [
        Tally(
            name: "Kai",
            transactions: [
                Transaction(amount: 100),
                Transaction(amount: -20, note: "Toy store"),
                Transaction(amount: 50, note: "Birthday gift")
            ]
        ),
        Tally(
            name: "Freya",
            transactions: [
                Transaction(amount: 100),
                Transaction(amount: -15, note: "Candy"),
                Transaction(amount: 30, note: "Chores")
            ]
        )
    ]
    return ContentView()
        .environmentObject(viewModel)
}

#Preview("Empty State") {
    let viewModel = TallyViewModel()
    viewModel.tallies = []
    return ContentView()
        .environmentObject(viewModel)
}
