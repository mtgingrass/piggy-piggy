import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    private let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    private let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // App Image and Title
                    VStack(spacing: 16) {
                        Image("piggy-trip")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .shadow(radius: 8)
                        
                        Text("Piggy Piggy")
                            .font(.system(size: 36, weight: .bold))
                        
                        Text("Version \(version) (\(build))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)
                    
                    // About Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("About")
                            .font(.title2)
                            .bold()
                        
                        Text("Piggy Piggy helps you track savings, spending, and allowances - built with kids in mind! It's perfect for managing money for school, family trips, or your own goals.")
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                    }
                    .padding(.horizontal)
                    
                    // Features Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Features")
                            .font(.title2)
                            .bold()
                        
                        VStack(alignment: .leading, spacing: 12) {
                            FeatureRow(icon: "plus.circle.fill", title: "Easy Tracking", description: "Add and manage multiple tallies for different people or goals")
                            FeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Visual Progress", description: "See your savings grow with clear, easy-to-understand displays")
                            FeatureRow(icon: "person.2.fill", title: "Family Friendly", description: "Perfect for teaching kids about money management")
                            FeatureRow(icon: "note.text", title: "Transaction Notes", description: "Keep track of what you're saving for or spending on")
                        }
                    }
                    .padding(.horizontal)
                    
                    // Developer Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Developer")
                            .font(.title2)
                            .bold()
                        
                        Text("Piggy Piggy was created by Mark Gingrass as a simple, effective tool for managing money and teaching financial literacy.")
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 20)
                }
            }
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
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.purple)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineSpacing(2)
            }
        }
    }
}

#Preview {
    AboutView()
} 
