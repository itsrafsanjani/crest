import SwiftUI

struct PrayerLocationEmptyStateView: View {
    var onOpenSettings: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: "location.slash.fill")
                    .foregroundStyle(.secondary)
                Text("Prayer times unavailable")
                    .font(.callout.weight(.medium))
            }
            Text("Set your location in Settings to enable.")
                .font(.caption)
                .foregroundStyle(.secondary)
            Button("Open Settings", action: onOpenSettings)
                .controlSize(.small)
                .padding(.top, 2)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
