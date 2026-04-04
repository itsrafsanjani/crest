import Foundation

enum MeetingService: String, CaseIterable {
    case googleMeet = "Google Meet"
    case zoom = "Zoom"
    case teams = "Microsoft Teams"
    case webex = "Webex"
    case other = "Meeting"
}

struct MeetingLink {
    let url: URL
    let service: MeetingService
}

enum MeetingLinkDetector {
    private static let patterns: [(service: MeetingService, regex: String)] = [
        (.googleMeet, #"https?://meet\.google\.com/[a-z\-]+"#),
        (.zoom, #"https?://[\w.]*zoom\.us/[jw]/\d+"#),
        (.teams, #"https?://teams\.microsoft\.com/l/meetup-join/[^\s]+"#),
        (.webex, #"https?://[\w.]*webex\.com/[\w./\-]+"#),
    ]

    static func detect(in text: String?) -> MeetingLink? {
        guard let text, !text.isEmpty else { return nil }

        for (service, pattern) in patterns {
            if let match = text.range(of: pattern, options: .regularExpression),
               let url = URL(string: String(text[match])) {
                return MeetingLink(url: url, service: service)
            }
        }

        if let genericURL = detectGenericMeetingURL(in: text) {
            return MeetingLink(url: genericURL, service: .other)
        }

        return nil
    }

    static func detect(location: String?, notes: String?) -> MeetingLink? {
        detect(in: location) ?? detect(in: notes)
    }

    private static func detectGenericMeetingURL(in text: String) -> URL? {
        let meetingKeywords = ["join", "meeting", "conference", "call", "video"]
        let urlPattern = #"https?://[^\s<>\"']+"#

        guard let regex = try? NSRegularExpression(pattern: urlPattern) else { return nil }
        let range = NSRange(text.startIndex..., in: text)
        let matches = regex.matches(in: text, range: range)

        for match in matches {
            guard let swiftRange = Range(match.range, in: text) else { continue }
            let urlString = String(text[swiftRange])
            let lower = urlString.lowercased()
            if meetingKeywords.contains(where: { lower.contains($0) }),
               let url = URL(string: urlString) {
                return url
            }
        }

        return nil
    }
}
