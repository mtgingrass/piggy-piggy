# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Piggy Piggy** is a SwiftUI-based iOS application for tracking children's digital allowances and transactions. It follows MVVM architecture with reactive UI updates and local persistence via UserDefaults.

## Development Commands

### Building and Running
- **Build**: `⌘+B` in Xcode or use Xcode's build system
- **Run**: `⌘+R` in Xcode simulator
- **Test**: `⌘+U` to run test suite
- **Archive**: Product → Archive (for App Store builds)

### No Package Manager Dependencies
This project uses only SwiftUI and Foundation frameworks - no external dependencies or package.json/Podfile.

## Architecture

### MVVM Pattern
- **Models**: `piggy-piggy/Models/Tally.swift` - Core data models (`Tally`, `Transaction`)
- **ViewModels**: `piggy-piggy/ViewModels/TallyViewModel.swift` - Single source of truth with `@MainActor`
- **Views**: `piggy-piggy/Views/` - Modular SwiftUI components with extensive previews

### Key Architectural Principles
- **Single ViewModel**: `TallyViewModel` manages all app state
- **Reactive Updates**: Uses `@Published` properties for UI reactivity  
- **Thread Safety**: All ViewModels marked with `@MainActor`
- **Automatic Persistence**: Changes auto-save to UserDefaults as JSON

## Data Architecture

### Core Models
```swift
struct Tally: Identifiable, Codable {
    var id: UUID
    var name: String
    var transactions: [Transaction]
    var allowanceAmount: Double
    var allowanceDay: Weekday
    // Balance computed from transactions
}

struct Transaction: Identifiable, Codable {
    var id: UUID
    var timestamp: Date
    var amount: Double // Positive = add, Negative = subtract
    var note: String?
    var isAllowance: Bool
}
```

### Persistence Strategy
- **Storage**: UserDefaults with JSON encoding/decoding
- **Auto-save**: All changes automatically persisted via `@Published` observers
- **Thread-safe**: All data operations on main actor

## Key Features

### Core Functionality
- Multi-child tally management
- Add/subtract funds with optional notes
- Automatic weekly allowances with configurable day-of-week
- Complete transaction history with timestamps
- Real-time balance calculations

### Advanced Features
- **Debug Mode**: Time travel simulation for testing (`#if DEBUG` blocks)
- **Allowance Automation**: Weekly payments with catch-up for missed weeks
- **Dark/Light Mode**: Theme switching support

## Important Files

### Entry Points
- `piggy_piggyApp.swift` - App entry point and root view configuration
- `ContentView.swift` - Main navigation container with tab/list views

### Core Components
- `TallyViewModel.swift` - All business logic and state management
- `TallyDetailView.swift` - Individual tally management screen
- `AllowanceSettingsView.swift` - Allowance configuration per child
- `DebugPanelView.swift` - Development tools (debug builds only)

## Development Notes

### Testing
- Uses Swift Testing framework (modern) + XCTest for UI tests
- Test files exist but are largely unimplemented
- Extensive SwiftUI previews serve as visual testing

### Code Quality
- Comprehensive SwiftUI previews for all components
- Clean separation of concerns with MVVM
- Type-safe throughout with proper Swift patterns
- No external dependencies - pure SwiftUI/Foundation

### Debug Features
- Debug panel accessible in debug builds for date simulation
- Time travel functionality for testing allowance automation
- Simulated data creation and cleanup tools

## Common Patterns

### UI State Management
- Use `@ObservedObject` for shared ViewModels
- Use `@State` for local UI state only
- All state changes trigger automatic persistence

### Adding New Features
1. Add business logic to `TallyViewModel`
2. Create SwiftUI view with proper previews
3. Connect via `@ObservedObject` pattern
4. Test with debug panel if needed

### Working with Allowances
- Allowances are special transactions with `isAllowance: true`
- Weekly automation handled by `processAllowances()` in ViewModel
- Date simulation available through debug panel for testing