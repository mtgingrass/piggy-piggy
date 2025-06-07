# Piggy Bank Tracker App

A SwiftUI-based iOS app that allows parents to track money given to and spent by their children. The app functions like a digital piggy bank, supporting multiple children and simple financial tracking.

## Overview

- **Platform**: iOS
- **Language**: Swift (SwiftUI only)
- **Persistence**: Local only for now (scalable for future sharing)
- **Architecture**: Scalable, testable, modular, clean SwiftUI
- **Primary Audience**: Parents tracking child spending

## Core Features

### 1. Tally (Piggy Bank) System

Each tally represents one child and tracks their total money balance, with history.

- **Example Default Tallies**: Kai ($100), Freya ($100)
- **Each Tally Includes**:
  - Child name (editable)
  - Current balance
  - List of transactions (positive and negative)
  - Ability to add or subtract funds

### 2. User Interface (UI)

Design principles: ultra-simple, intuitive, child-friendly aesthetics

#### Home Screen
- List of all current tallies (e.g., Kai, Freya)
- Each row shows:
  - Name of child
  - Current balance
  - Subtract button (for quick spend logging)
- Tap on Row: Opens detail view of that tally
- Swipe-to-Delete: Deletes the tally (with confirmation prompt)
- Plus (+) Button: Adds a new tally

#### Detail View (per Tally)
- Full transaction history (timestamp, amount, optional note)
- Balance summary
- Edit name
- Buttons:
  - Add funds
  - Subtract funds

### 3. Interactions and Gestures
- Tap Row: Navigate to full transaction view for that child
- Button in Row: Quick subtract (e.g., subtract $5, with optional note)
- Swipe to Delete: Confirm before removing a tally
- Optional swipe (future): add funds

## Data Model

```swift
struct Tally: Identifiable, Codable {
    var id: UUID
    var name: String
    var transactions: [Transaction]

    var balance: Double {
        transactions.map { $0.amount }.reduce(0, +)
    }
}

struct Transaction: Identifiable, Codable {
    var id: UUID
    var timestamp: Date
    var amount: Double // Positive = deposit, Negative = spending
    var note: String?
}
```

## Persistence
- Use @AppStorage or UserDefaults initially
- Migrate to CoreData or file-based storage as needed
- All data stored on-device for now

## App Launch Behavior
- Prepopulate with two sample children: Kai and Freya ($100 each)
- User can edit, delete, or add tallies freely

## Testing Requirements

### Unit Tests
- Balance calculation
- Transaction logging
- Add/Subtract logic

### UI Tests
- Row interactions
- Adding/deleting tallies
- Editing names and balances

## Future Scalability
- Sync with iCloud or external database
- Multi-device sharing
- Visual charts and trends

## Design Goals
- Follow Apple's Human Interface Guidelines
- SwiftUI-first, using modern declarative patterns
- Avoid clutter and make the experience joyful and effortless

---

This document serves as the reference point for any AI agent generating code, running tests, or iterating on the design. All features and structure should comply with iOS development best practices and be built to support iterative expansion. 