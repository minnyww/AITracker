import SwiftUI

struct StackedBarView: View {
    let services: [UsageData]
    let hasError: Bool

    init(services: [UsageData] = [], hasError: Bool = false) {
        self.services = services
        self.hasError = hasError
    }

    var body: some View {
        HStack(spacing: 3) {
            if services.isEmpty {
                Image(systemName: "sparkles")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            } else {
                ForEach(services) { service in
                    serviceIcon(for: service)
                }
            }

            if hasError {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 8))
                    .foregroundColor(.orange)
            }
        }
        .frame(height: 18)
    }

    private func serviceIcon(for service: UsageData) -> some View {
        Group {
            if service.service == .zai {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: service.isAvailable ? [.cyan, .blue] : [.gray, .gray.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            } else {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: service.isAvailable ? [.purple, .pink] : [.gray, .gray.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        }
    }
}
