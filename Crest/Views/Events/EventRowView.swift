import SwiftUI
import EventKit

struct EventRowView: View {
    let event: EKEvent

    @State private var isPresented = false

    var body: some View {
        Button(action: { isPresented.toggle() }) {
            HStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(Color(cgColor: event.calendar.cgColor))
                    .frame(width: 3)
                    .padding(.vertical, 4)

                VStack(alignment: .leading, spacing: 2) {
                    Text(event.title ?? "Untitled")
                        .font(.body.weight(.medium))
                        .lineLimit(1)

                    Text(DateFormatting.eventTimeRange(
                        start: event.startDate,
                        end: event.endDate,
                        isAllDay: event.isAllDay
                    ))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                .padding(.leading, 10)

                Spacer()

                if meetingLink != nil {
                    Image(systemName: "video.fill")
                        .font(.caption)
                        .foregroundStyle(Color.accentColor)
                        .padding(.trailing, 6)
                }

                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .popover(isPresented: $isPresented, arrowEdge: .leading) {
            EventDetailView(event: event, meetingLink: meetingLink)
        }
    }

    private var meetingLink: MeetingLink? {
        MeetingLinkDetector.detect(
            location: event.location,
            notes: event.notes,
            url: event.url
        )
    }
}
