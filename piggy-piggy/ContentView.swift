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

struct CustomTitleView: View {
    let viewModel: TallyViewModel
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 2) {
                Text("Piggy")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.pink, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .pink.opacity(0.3), radius: 2, x: 0, y: 2)
                Text("Piggy")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .purple.opacity(0.3), radius: 2, x: 0, y: 2)
            }
            
            Text(viewModel.currentDate, style: .date)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color.secondary.opacity(0.1))
                )
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = TallyViewModel()
    @StateObject private var themeManager = ThemeManager()
    @State private var showingAddTally = false
    @State private var showingAbout = false
    @State private var newTallyName = ""
    @State private var tallyToDelete: Tally?
    @State private var showingDeleteConfirmation = false
    @State private var showingDebugPanel = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.tallies) { tally in
                        TallyRow(viewModel: viewModel, tally: tally)
                            .contextMenu {
                                Button(role: .destructive) {
                                    tallyToDelete = tally
                                    showingDeleteConfirmation = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
                .padding(.vertical, 20)
            }
            .background(
                LinearGradient(
                    colors: [Color(.systemGroupedBackground), Color(.systemBackground)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .toolbar {
                ToolbarItem(placement: .principal) {
                    CustomTitleView(viewModel: viewModel)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingAddTally = true }) {
                        Image(systemName: "plus.circle.fill")
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        // Debug toggle (only in debug builds)
                        #if DEBUG
                        Button(action: { showingDebugPanel = true }) {
                            Image(systemName: "ladybug")
                                .foregroundColor(.orange)
                        }
                        #endif
                        
                        Button(action: { showingAbout = true }) {
                            Image(systemName: "heart.fill")
                                .font(.title2)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.red, .pink],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        Button(action: { themeManager.isDarkMode.toggle() }) {
                            Image(systemName: themeManager.isDarkMode ? "sun.max.fill" : "moon.fill")
                                .font(.title2)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: themeManager.isDarkMode ? [.yellow, .orange] : [.indigo, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                    }
                }
            }
            .alert("New Tally", isPresented: $showingAddTally) {
                TextField("Name", text: $newTallyName)
                Button("Cancel", role: .cancel) {
                    newTallyName = ""
                }
                Button("Add") {
                    if !newTallyName.isEmpty {
                        viewModel.addTally(name: newTallyName)
                        newTallyName = ""
                    }
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
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
            .sheet(isPresented: $showingDebugPanel) {
                NavigationView {
                    DebugPanelView(viewModel: viewModel)
                }
                .navigationViewStyle(.stack)
            }
        }
        .navigationViewStyle(.stack)
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