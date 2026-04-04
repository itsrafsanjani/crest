import SwiftUI

struct PlaceholderSettingsView: View {
    let title: String
    let description: String

    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "hammer.fill")
                .font(.system(size: 36))
                .foregroundStyle(.tertiary)
            Text(title)
                .font(.title2.weight(.medium))
            Text(description)
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
