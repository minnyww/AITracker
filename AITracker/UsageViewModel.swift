import Foundation
import Combine

enum ServiceType: String, CaseIterable {
    case zai = "Z.ai"
    case osiris = "Osiris"
}

struct QuotaInfo: Identifiable {
    let id = UUID()
    let period: String
    let used: Int
    let limit: Int
    let resetAt: Date?
}

struct UsageData: Identifiable {
    let id = UUID()
    let service: ServiceType
    let balance: Double?
    let requestsToday: Int?
    let tokensUsed: Int?
    let nextResetTime: Date?
    let quotas: [QuotaInfo]
    let lastUpdated: Date
    let isAvailable: Bool
    let error: String?
}

@MainActor
final class UsageViewModel: ObservableObject {
    @Published var usageData: [UsageData] = []
    @Published var lastError: String?

    private var cancellables = Set<AnyCancellable>()
    private var refreshTimer: Timer?

    private let zaiProvider = ZaiUsageProvider()
    private let osirisProvider = OsirisUsageProvider()

    init() {
        loadUsage()
    }

    func startMonitoring() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.loadUsage()
            }
        }
        loadUsage()
    }

    func stopMonitoring() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }

    func loadUsage() {
        Task {
            var results: [UsageData] = []

            async let zai = zaiProvider.fetchUsage()
            async let osiris = osirisProvider.fetchUsage()

            let (zaiResult, osirisResult) = await (zai, osiris)
            results.append(zaiResult)
            results.append(osirisResult)

            usageData = results
            lastError = results.first(where: { $0.error != nil })?.error
        }
    }
}
