import SwiftUI
import EventKit

struct EventDetailView: View {
    let event: EKEvent
    let meetingLink: MeetingLink?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let meetingLink {
                Button(action: { NSWorkspace.shared.open(meetingLink.url) }) {
                    Label("Join \(meetingLink.service.rawValue)", systemImage: "video.fill")
                        .font(.callout.weight(.medium))
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }

            if let location = event.location, !location.isEmpty {
                detailRow(icon: "mappin.and.ellipse", text: location)
            }

            if let attendees = event.attendees, !attendees.isEmpty {
                detailRow(
                    icon: "person.2",
                    text: attendees
                        .compactMap { $0.name ?? $0.url.absoluteString }
                        .joined(separator: ", ")
                )
            }

            if let notes = event.notes, !notes.isEmpty {
                detailRow(icon: "note.text", text: notes)
                    .lineLimit(4)
            }

            if let url = event.url {
                Button(action: { NSWorkspace.shared.open(url) }) {
                    Label("Open Link", systemImage: "link")
                        .font(.caption)
                }
                .buttonStyle(.plain)
                .foregroundStyle(Color.accentColor)
            }
        }
        .padding(.horizontal, 28)
        .padding(.bottom, 10)
    }

    private func detailRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 14)
            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
                .textSelection(.enabled)
        }
    }
}
