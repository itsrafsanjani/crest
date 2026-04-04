import SwiftUI
import EventKit

struct EventRowView: View {
    let event: EKEvent

    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: { withAnimation(.easeInOut(duration: 0.2)) { isExpanded.toggle() } }) {
                HStack(alignment: .top, spacing: 8) {
                    Circle()
                        .fill(Color(cgColor: event.calendar.cgColor))
                        .frame(width: 8, height: 8)
                        .padding(.top, 5)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(event.title ?? "Untitled")
                            .font(.callout.weight(.medium))
                            .lineLimit(1)

                        Text(DateFormatting.eventTimeRange(
                            start: event.startDate,
                            end: event.endDate,
                            isAllDay: event.isAllDay
                        ))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }

                    Spacer()

                    if meetingLink != nil {
                        Image(systemName: "video.fill")
                            .font(.caption)
                            .foregroundStyle(.blue)
                            .padding(.top, 4)
                    }

                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .padding(.top, 4)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                EventDetailView(event: event, meetingLink: meetingLink)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
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
