import Foundation

protocol UsageProvider {
    func fetchUsage() async -> UsageData
}

// MARK: - Z.ai Response Models

struct ZaiQuotaResponse: Decodable {
    let code: Int
    let msg: String
    let success: Bool
    let data: ZaiQuotaData?
}

struct ZaiQuotaData: Decodable {
    let limits: [ZaiLimit]?
    let level: String?
}

struct ZaiLimit: Decodable {
    let type: String?
    let unit: Int?
    let number: Int?
    let usage: Int?
    let currentValue: Int?
    let remaining: Int?
    let percentage: Int?
    let nextResetTime: Int?
    let usageDetails: [ZaiUsageDetail]?
}

struct ZaiUsageDetail: Decodable {
    let modelCode: String?
    let usage: Int?
}

// MARK: - Osiris Response Models

struct OsirisKeysResponse: Decodable {
    let keys: [OsirisKey]?
}

struct OsirisKey: Decodable {
    let keyId: String?
    let name: String?
    let keyPrefix: String?
    let keyType: String?
    let status: String?
    let balance: Int?
    let balanceUsd: Double?
    let requestQuotas: [OsirisRequestQuota]?
    let usageCostUsd: Double?
    let totalUsed: Int?
    let lastUsedAt: String?
}

struct OsirisRequestQuota: Decodable {
    let limit: Int?
    let period: String?
    let resetAt: String?
    let used: Int?
}

// MARK: - Z.ai Provider

final class ZaiUsageProvider: UsageProvider {
    private let session = URLSession.shared

    func fetchUsage() async -> UsageData {
        guard let apiKey = UserDefaults.standard.string(forKey: "zai_api_key"), !apiKey.isEmpty else {
            return UsageData(
                service: .zai,
                balance: nil,
                requestsToday: nil,
                tokensUsed: nil,
                nextResetTime: nil,
                quotas: [],
                lastUpdated: Date(),
                isAvailable: false,
                error: "API key not configured"
            )
        }

        guard let url = URL(string: "https://api.z.ai/api/monitor/usage/quota/limit") else {
            return UsageData(
                service: .zai,
                balance: nil,
                requestsToday: nil,
                tokensUsed: nil,
                nextResetTime: nil,
                quotas: [],
                lastUpdated: Date(),
                isAvailable: false,
                error: "Invalid API URL"
            )
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                return UsageData(
                    service: .zai,
                    balance: nil,
                    requestsToday: nil,
                    tokensUsed: nil,
                    nextResetTime: nil,
                    quotas: [],
                    lastUpdated: Date(),
                    isAvailable: false,
                    error: "API request failed"
                )
            }

            let quotaResponse = try JSONDecoder().decode(ZaiQuotaResponse.self, from: data)

            guard quotaResponse.success, let quotaData = quotaResponse.data else {
                return UsageData(
                    service: .zai,
                    balance: nil,
                    requestsToday: nil,
                    tokensUsed: nil,
                    nextResetTime: nil,
                    quotas: [],
                    lastUpdated: Date(),
                    isAvailable: false,
                    error: quotaResponse.msg
                )
            }

            let timeLimit = quotaData.limits?.first { $0.type == "TIME_LIMIT" }
            let tokensLimit = quotaData.limits?.first { $0.type == "TOKENS_LIMIT" }

            let nextReset = timeLimit?.nextResetTime.flatMap { timestamp in
                Date(timeIntervalSince1970: TimeInterval(timestamp) / 1000)
            }

            var quotas: [QuotaInfo] = []
            if let timeLimit = timeLimit {
                quotas.append(QuotaInfo(
                    period: "Time Limit",
                    used: timeLimit.currentValue ?? 0,
                    limit: 100,
                    resetAt: nextReset
                ))
            }
            if let tokensLimit = tokensLimit {
                quotas.append(QuotaInfo(
                    period: "Tokens",
                    used: tokensLimit.percentage ?? 0,
                    limit: 100,
                    resetAt: nil
                ))
            }

            return UsageData(
                service: .zai,
                balance: Double(timeLimit?.remaining ?? 0),
                requestsToday: timeLimit?.currentValue,
                tokensUsed: tokensLimit?.percentage,
                nextResetTime: nextReset,
                quotas: quotas,
                lastUpdated: Date(),
                isAvailable: true,
                error: nil
            )
        } catch {
            return UsageData(
                service: .zai,
                balance: nil,
                requestsToday: nil,
                tokensUsed: nil,
                nextResetTime: nil,
                quotas: [],
                lastUpdated: Date(),
                isAvailable: false,
                error: error.localizedDescription
            )
        }
    }
}

// MARK: - Osiris Provider

final class OsirisUsageProvider: UsageProvider {
    private let session = URLSession.shared

    func fetchUsage() async -> UsageData {
        guard let token = UserDefaults.standard.string(forKey: "osiris_token"), !token.isEmpty else {
            return UsageData(
                service: .osiris,
                balance: nil,
                requestsToday: nil,
                tokensUsed: nil,
                nextResetTime: nil,
                quotas: [],
                lastUpdated: Date(),
                isAvailable: false,
                error: "Token not configured"
            )
        }

        guard let url = URL(string: "https://osiris-code.com/api/keys") else {
            return UsageData(
                service: .osiris,
                balance: nil,
                requestsToday: nil,
                tokensUsed: nil,
                nextResetTime: nil,
                quotas: [],
                lastUpdated: Date(),
                isAvailable: false,
                error: "Invalid API URL"
            )
        }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("osiris_token=\(token)", forHTTPHeaderField: "Cookie")

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                return UsageData(
                    service: .osiris,
                    balance: nil,
                    requestsToday: nil,
                    tokensUsed: nil,
                    nextResetTime: nil,
                    quotas: [],
                    lastUpdated: Date(),
                    isAvailable: false,
                    error: "Invalid response"
                )
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                return UsageData(
                    service: .osiris,
                    balance: nil,
                    requestsToday: nil,
                    tokensUsed: nil,
                    nextResetTime: nil,
                    quotas: [],
                    lastUpdated: Date(),
                    isAvailable: false,
                    error: "HTTP \(httpResponse.statusCode)"
                )
            }

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let keysResponse = try decoder.decode(OsirisKeysResponse.self, from: data)

            guard let keys = keysResponse.keys, !keys.isEmpty else {
                return UsageData(
                    service: .osiris,
                    balance: nil,
                    requestsToday: nil,
                    tokensUsed: nil,
                    nextResetTime: nil,
                    quotas: [],
                    lastUpdated: Date(),
                    isAvailable: false,
                    error: "No keys found"
                )
            }

            let totalBalance = keys.compactMap { $0.balanceUsd }.reduce(0, +)
            let totalUsed = keys.compactMap { $0.totalUsed }.reduce(0, +)

            var quotas: [QuotaInfo] = []
            for key in keys {
                if let requestQuotas = key.requestQuotas {
                    for quota in requestQuotas {
                        if let period = quota.period, let limit = quota.limit, let used = quota.used {
                            let resetDate = quota.resetAt.flatMap { ISO8601DateFormatter().date(from: $0) }
                            quotas.append(QuotaInfo(
                                period: period.capitalized,
                                used: used,
                                limit: limit,
                                resetAt: resetDate
                            ))
                        }
                    }
                }
            }

            let dailyQuota = quotas.first { $0.period == "Daily" }

            return UsageData(
                service: .osiris,
                balance: totalBalance,
                requestsToday: dailyQuota?.used,
                tokensUsed: totalUsed,
                nextResetTime: dailyQuota?.resetAt,
                quotas: quotas,
                lastUpdated: Date(),
                isAvailable: true,
                error: nil
            )
        } catch {
            return UsageData(
                service: .osiris,
                balance: nil,
                requestsToday: nil,
                tokensUsed: nil,
                nextResetTime: nil,
                quotas: [],
                lastUpdated: Date(),
                isAvailable: false,
                error: error.localizedDescription
            )
        }
    }
}
