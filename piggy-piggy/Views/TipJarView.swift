import SwiftUI
import StoreKit

class TipJarStore: ObservableObject {
    @Published var products: [Product] = []
    @Published var purchaseInProgress: Bool = false
    @Published var purchaseSuccess: Bool = false
    @Published var errorMessage: String?
    
    let productIDs: [String] = ["tip.small", "tips.medium"]
    
    init() {
        Task {
            await requestProducts()
        }
    }
    
    @MainActor
    func requestProducts() async {
        do {
            products = try await Product.products(for: productIDs)
        } catch {
            errorMessage = "Failed to load products."
        }
    }
    
    @MainActor
    func purchase(_ product: Product) async {
        purchaseInProgress = true
        defer { purchaseInProgress = false }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(_):
                    purchaseSuccess = true
                case .unverified(_, _):
                    errorMessage = "Purchase could not be verified."
                }
            case .userCancelled:
                break
            case .pending:
                break
            @unknown default:
                break
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct TipJarView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var store = TipJarStore()
    @State private var showingThankYou = false
    
    private let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    private let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // App Image and Title
                    VStack(spacing: 16) {
                        Image("piggy-trip")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 180)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .shadow(radius: 8)
                        
                        Text("Piggy Piggy")
                            .font(.system(size: 32, weight: .bold))
                        
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
                        
                        Text("Piggy Piggy helps you track savings, spending, and allowances (built for kids in mind!). It's perfect for managing money for school, family trips, or your own goals.")
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    // Tip Jar Section
                    VStack(spacing: 16) {
                        Text("Support the Developer")
                            .font(.title2)
                            .bold()
                        
                        Text("If you're enjoying Piggy Piggy, consider a donation. Your support helps keep the app running and future updates coming.")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        // Tip Options
                        if store.products.isEmpty {
                            ProgressView("Loading...")
                        } else {
                            HStack(spacing: 16) {
                                ForEach(store.products, id: \.id) { product in
                                    TipProductButton(product: product, isLoading: store.purchaseInProgress) {
                                        Task {
                                            await store.purchase(product)
                                        }
                                    }
                                }
                            }
                            .padding(.top, 8)
                        }
                        if let error = store.errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    )
                    .padding(.horizontal)
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
            .onChange(of: store.purchaseSuccess) { newValue in
                if newValue {
                    showingThankYou = true
                    store.purchaseSuccess = false
                }
            }
            .alert("Thank You!", isPresented: $showingThankYou) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your support means the world to me! 🎉")
            }
        }
    }
}

struct TipProductButton: View {
    let product: Product
    let isLoading: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(product.displayPrice)
                    .font(.system(size: 24, weight: .bold))
                Text(product.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.purple.opacity(0.15))
            )
            .foregroundColor(.primary)
        }
        .disabled(isLoading)
    }
}

#Preview {
    TipJarView()
} 
