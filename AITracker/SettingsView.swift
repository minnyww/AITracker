import SwiftUI

struct SettingsView: View {
    @AppStorage("zai_api_key") private var zaiApiKey = ""
    @AppStorage("osiris_token") private var osirisToken = ""
    @AppStorage("auto_refresh") private var autoRefresh = true
    @AppStorage("refresh_interval") private var refreshInterval = 300

    @Environment(\.dismiss) private var dismiss
    @State private var showZaiKey = false
    @State private var showOsirisToken = false

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(nsColor: .windowBackgroundColor),
                    Color(nsColor: .controlBackgroundColor)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                headerSection

                Divider()
                    .background(
                        LinearGradient(
                            colors: [.clear, .purple.opacity(0.3), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                // Content
                ScrollView {
                    VStack(spacing: 20) {
                        // Z.ai Section
                        apiKeySection(
                            title: "Z.ai",
                            icon: "brain.head.profile",
                            colors: [.blue, .cyan],
                            placeholder: "Enter your Z.ai API key",
                            text: $zaiApiKey,
                            isSecure: $showZaiKey
                        )

                        // Osiris Section
                        apiKeySection(
                            title: "Osiris",
                            icon: "bolt.fill",
                            colors: [.purple, .pink],
                            placeholder: "Enter your osiris_token from cookie",
                            text: $osirisToken,
                            isSecure: $showOsirisToken
                        )

                        // Refresh Settings
                        refreshSection
                    }
                    .padding()
                }

                // Footer
                footerSection
            }
        }
        .frame(width: 420, height: 480)
    }

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Settings")
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                Text("Configure your API keys")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
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
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    private func apiKeySection(
        title: String,
        icon: String,
        colors: [Color],
        placeholder: String,
        text: Binding<String>,
        isSecure: Binding<Bool>
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: colors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 28, height: 28)

                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }

                Text(title)
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.semibold)
            }

            // Input field
            HStack(spacing: 8) {
                if isSecure.wrappedValue {
                    SecureField(placeholder, text: text)
                        .textFieldStyle(.plain)
                } else {
                    TextField(placeholder, text: text)
                        .textFieldStyle(.plain)
                }

                Button(action: { isSecure.wrappedValue.toggle() }) {
                    Image(systemName: isSecure.wrappedValue ? "eye.slash.fill" : "eye.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                LinearGradient(
                                    colors: colors.map { $0.opacity(0.3) },
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            LinearGradient(
                                colors: colors.map { $0.opacity(0.2) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }

    private var refreshSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [.green, .mint],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 28, height: 28)

                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }

                Text("Refresh")
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.semibold)
            }

            Toggle("Auto-refresh usage data", isOn: $autoRefresh)
                .font(.caption)

            if autoRefresh {
                Picker("Interval", selection: $refreshInterval) {
                    Text("1 min").tag(60)
                    Text("5 min").tag(300)
                    Text("15 min").tag(900)
                    Text("30 min").tag(1800)
                }
                .pickerStyle(.segmented)
                .labelsHidden()
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            LinearGradient(
                                colors: [.green.opacity(0.2), .mint.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }

    private var footerSection: some View {
        HStack {
            Button(action: { dismiss() }) {
                Text("Cancel")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)

            Spacer()

            Button(action: { dismiss() }) {
                Text("Save")
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}
