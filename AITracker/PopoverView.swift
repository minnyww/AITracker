import SwiftUI

struct PopoverView: View {
    @ObservedObject var viewModel: UsageViewModel
    @State private var showingSettings = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(nsColor: .controlBackgroundColor),
                    Color(nsColor: .windowBackgroundColor)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                headerSection

                Divider()
                    .background(
                        LinearGradient(
                            colors: [.clear, .purple.opacity(0.3), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(viewModel.usageData) { service in
                            ServiceCard(service: service)
                        }
                    }
                    .padding()
                }

                Divider()
                    .background(
                        LinearGradient(
                            colors: [.clear, .blue.opacity(0.3), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                footerSection
            }
        }
        .frame(width: 360, height: 500)
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("AI Usage Tracker")
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                Text("\(viewModel.usageData.count) services connected")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Button(action: { showingSettings = true }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.gray, .gray.opacity(0.6)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var footerSection: some View {
        HStack {
            Label {
                Text("Updated just now")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            } icon: {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            Spacer()
            Button(action: { viewModel.loadUsage() }) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

struct ServiceCard: View {
    let service: UsageData
    @State private var isHovered = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            headerRow
            if let error = service.error {
                errorView(error)
            } else {
                statsView
                quotaSection
                if let resetTime = service.nextResetTime {
                    nextResetView(resetTime)
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            LinearGradient(
                                colors: service.service == .zai
                                    ? [.blue.opacity(0.5), .cyan.opacity(0.3)]
                                    : [.purple.opacity(0.5), .pink.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(
            color: (service.service == .zai ? Color.blue : Color.purple).opacity(isHovered ? 0.3 : 0.1),
            radius: isHovered ? 8 : 4,
            y: 2
        )
        .scaleEffect(isHovered ? 1.02 : 1)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover { hovering in isHovered = hovering }
    }

    private var headerRow: some View {
        HStack {
            serviceIcon
            VStack(alignment: .leading, spacing: 2) {
                Text(service.service.rawValue)
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.semibold)
                Text(service.service == .zai ? "GLM-5.2 Powered" : "API Gateway")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            Spacer()
            statusBadge
        }
    }

    private var serviceIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    LinearGradient(
                        colors: service.service == .zai ? [.blue, .cyan] : [.purple, .pink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 36, height: 36)

            Image(systemName: service.service == .zai ? "brain.head.profile" : "bolt.fill")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
        }
        .shadow(
            color: (service.service == .zai ? Color.blue : Color.purple).opacity(0.4),
            radius: 4,
            y: 2
        )
    }

    private var statusBadge: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(service.isAvailable ? Color.green : Color.red)
                .frame(width: 6, height: 6)
                .shadow(color: service.isAvailable ? .green : .red, radius: 3)
            Text(service.isAvailable ? "Active" : "Inactive")
                .font(.caption2)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(service.isAvailable ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
        )
    }

    private func errorView(_ error: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.caption)
                .foregroundColor(.orange)
            Text(error)
                .font(.caption)
                .foregroundColor(.orange)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.orange.opacity(0.1))
        )
    }

    private var statsView: some View {
        HStack(spacing: 12) {
            if service.service == .zai {
                GradientStat(label: "Remaining", value: "\(Int(service.balance ?? 0))%", colors: [.green, .mint])
                GradientStat(label: "Used", value: "\(service.requestsToday ?? 0)%", colors: [.orange, .yellow])
                GradientStat(label: "Quota", value: "\(service.tokensUsed ?? 0)%", colors: [.blue, .cyan])
            } else {
                GradientStat(label: "Balance", value: formatBalance(service.balance), colors: [.green, .mint])
                GradientStat(label: "Daily", value: "\(service.requestsToday ?? 0)", colors: [.orange, .yellow])
                GradientStat(label: "Total", value: "\(service.tokensUsed ?? 0)", colors: [.blue, .cyan])
            }
        }
    }

    private var quotaSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(service.quotas) { quota in
                quotaRow(quota)
            }
        }
    }

    private func quotaRow(_ quota: QuotaInfo) -> some View {
        HStack {
            Text(quota.period)
                .font(.caption2)
                .foregroundColor(.secondary)
                .frame(width: 60, alignment: .leading)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(
                            LinearGradient(
                                colors: progressColor(for: quota),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * progress(for: quota), height: 6)
                }
            }
            .frame(height: 6)

            Text("\(quota.used)/\(quota.limit)")
                .font(.system(.caption2, design: .rounded))
                .foregroundColor(.secondary)
                .frame(width: 50, alignment: .trailing)
        }
    }

    private func progress(for quota: QuotaInfo) -> CGFloat {
        guard quota.limit > 0 else { return 0 }
        return min(1.0, CGFloat(quota.used) / CGFloat(quota.limit))
    }

    private func progressColor(for quota: QuotaInfo) -> [Color] {
        let pct = progress(for: quota)
        if pct > 0.8 { return [.red, .orange] }
        if pct > 0.5 { return [.orange, .yellow] }
        return [.green, .mint]
    }

    private func nextResetView(_ date: Date) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "arrow.clockwise")
                .font(.system(size: 9))
                .foregroundColor(.secondary)
            Text("Resets \(date, style: .relative)")
                .font(.system(.caption2, design: .rounded))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.blue.opacity(0.08))
        )
    }

    private func formatBalance(_ balance: Double?) -> String {
        guard let balance = balance else { return "-" }
        return String(format: "$%.2f", balance)
    }
}

struct GradientStat: View {
    let label: String
    let value: String
    let colors: [Color]

    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(.caption, design: .rounded))
                .fontWeight(.bold)
                .foregroundStyle(
                    LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom)
                )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial)
        )
    }
}
