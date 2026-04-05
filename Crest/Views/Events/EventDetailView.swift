import SwiftUI
import EventKit

struct EventDetailView: View {
    let event: EKEvent
    let meetingLink: MeetingLink?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header

            if let meetingLink {
                Button(action: { NSWorkspace.shared.open(meetingLink.url) }) {
                    HStack(spacing: 8) {
                        Image(systemName: "video.fill")
                            .font(.callout)
                            .foregroundStyle(Color.accentColor)
                        Text("Join \(meetingLink.service.rawValue)")
                            .font(.callout.weight(.medium))
                            .foregroundStyle(Color.accentColor)
                    }
                }
                .buttonStyle(.plain)
            }

            if let recurrenceText {
                Text(recurrenceText)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.primary)
            }

            if let location = event.location, !location.isEmpty {
                detailRow(icon: "mappin.and.ellipse", text: location)
            }

            if let cleanedNotes {
                Divider()
                    .padding(.vertical, 2)
                Text(cleanedNotes)
                    .font(.callout)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                    .textSelection(.enabled)
            }

            if let attendees = sortedAttendees, !attendees.isEmpty {
                Divider()
                    .padding(.vertical, 2)
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(Array(attendees.enumerated()), id: \.offset) { _, attendee in
                        attendeeRow(attendee)
                    }
                }
            }
        }
        .padding(16)
        .frame(width: 320)
    }

    // MARK: - Notes

    private var cleanedNotes: String? {
        guard let notes = event.notes else { return nil }
        let separatorPattern = #"^[-:~\s]{8,}$"#
        let lines = notes.components(separatedBy: .newlines)
        var result: [String] = []
        var inSeparatedBlock = false
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.range(of: separatorPattern, options: .regularExpression) != nil {
                inSeparatedBlock.toggle()
                continue
            }
            if inSeparatedBlock { continue }
            let lower = trimmed.lowercased()
            if lower.hasPrefix("join with ") { continue }
            if lower.hasPrefix("learn more about ") { continue }
            if lower.hasPrefix("http://") || lower.hasPrefix("https://"),
               !trimmed.contains(" ") { continue }
            result.append(line)
        }
        let cleaned = result.joined(separator: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return cleaned.isEmpty ? nil : cleaned
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(event.title ?? "Untitled")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            if event.isAllDay {
                Text(allDayDateText)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            } else {
                if let relative = relativeTimeText {
                    Text(relative)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                Text(timedDateText)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var allDayDateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM, yyyy"
        return formatter.string(from: event.startDate)
    }

    private var timedDateText: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM, yyyy"
        let datePart = dateFormatter.string(from: event.startDate)

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        let start = timeFormatter.string(from: event.startDate)
        let end = timeFormatter.string(from: event.endDate)
        return "\(datePart), \(start) – \(end)"
    }

    private var relativeTimeText: String? {
        guard let start = event.startDate else { return nil }
        let now = Date()
        let end = event.endDate ?? start

        if now >= start && now <= end {
            return "Now"
        }

        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: start, relativeTo: now)
    }

    // MARK: - Recurrence

    private var recurrenceText: String? {
        guard let rule = event.recurrenceRules?.first else { return nil }
        return formatRecurrence(rule)
    }

    private func formatRecurrence(_ rule: EKRecurrenceRule) -> String {
        let interval = rule.interval
        let everyPrefix = interval > 1 ? "Every \(interval) " : "Every "

        switch rule.frequency {
        case .daily:
            return interval > 1 ? "Repeats Every \(interval) Days" : "Repeats Daily"
        case .weekly:
            if let days = rule.daysOfTheWeek, !days.isEmpty {
                let names = days.map { weekdayName($0.dayOfTheWeek) }
                return "Repeats \(everyPrefix)\(names.joined(separator: " and "))"
            }
            return interval > 1 ? "Repeats Every \(interval) Weeks" : "Repeats Weekly"
        case .monthly:
            return interval > 1 ? "Repeats Every \(interval) Months" : "Repeats Monthly"
        case .yearly:
            return interval > 1 ? "Repeats Every \(interval) Years" : "Repeats Yearly"
        @unknown default:
            return "Repeats"
        }
    }

    private func weekdayName(_ weekday: EKWeekday) -> String {
        switch weekday {
        case .sunday: return "Sunday"
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        @unknown default: return ""
        }
    }

    // MARK: - Attendees

    private var sortedAttendees: [EKParticipant]? {
        guard let attendees = event.attendees else { return nil }
        return attendees.sorted { lhs, rhs in
            if lhs.participantRole == .chair && rhs.participantRole != .chair { return true }
            if rhs.participantRole == .chair && lhs.participantRole != .chair { return false }
            return (lhs.name ?? "") < (rhs.name ?? "")
        }
    }

    private func attendeeRow(_ attendee: EKParticipant) -> some View {
        HStack(spacing: 8) {
            statusIcon(for: attendee.participantStatus)
                .font(.system(size: 13))
                .frame(width: 16)

            Text(displayName(for: attendee))
                .font(.callout)
                .foregroundStyle(.primary)
                .lineLimit(1)
                .truncationMode(.tail)

            if attendee.participantRole == .chair {
                Text("(organizer)")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            } else if attendee.isCurrentUser {
                Text("(me)")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
    }

    @ViewBuilder
    private func statusIcon(for status: EKParticipantStatus) -> some View {
        switch status {
        case .accepted:
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
        case .declined:
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(.red)
        case .tentative:
            Image(systemName: "questionmark.circle.fill")
                .foregroundStyle(.orange)
        case .pending, .unknown:
            Image(systemName: "questionmark.circle")
                .foregroundStyle(.secondary)
        default:
            Image(systemName: "circle")
                .foregroundStyle(.secondary)
        }
    }

    private func displayName(for attendee: EKParticipant) -> String {
        if let name = attendee.name, !name.isEmpty { return name }
        let urlString = attendee.url.absoluteString
        if urlString.lowercased().hasPrefix("mailto:") {
            return String(urlString.dropFirst("mailto:".count))
        }
        return urlString
    }

    // MARK: - Rows

    private func detailRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .font(.callout)
                .foregroundStyle(.secondary)
                .frame(width: 16)
            Text(text)
                .font(.callout)
                .foregroundStyle(.secondary)
                .textSelection(.enabled)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
