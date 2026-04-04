import Foundation

enum MeetingService: String, CaseIterable, Identifiable {
    // Tier 1 — most common
    case googleMeet = "Google Meet"
    case zoom = "Zoom"
    case teams = "Microsoft Teams"
    case webex = "Webex"
    case gotoMeeting = "GoTo Meeting"
    case bluejeans = "BlueJeans"
    case whereby = "Whereby"

    // Tier 2 — common
    case chime = "Amazon Chime"
    case jitsi = "Jitsi Meet"
    case skype = "Skype"
    case slack = "Slack"
    case discord = "Discord"
    case ringcentral = "RingCentral"
    case dialpad = "Dialpad"
    case meet8x8 = "8x8 Meet"
    case vonage = "Vonage"
    case lifesize = "Lifesize"
    case starleaf = "StarLeaf"
    case facetime = "FaceTime"

    // Tier 3 — specialized
    case livestorm = "Livestorm"
    case demio = "Demio"
    case streamyard = "StreamYard"
    case hopin = "Hopin"
    case airmeet = "Airmeet"
    case gather = "Gather"
    case butter = "Butter"
    case kumospace = "Kumospace"
    case rally = "Rally"
    case pop = "Pop"
    case tandem = "Tandem"
    case vowel = "Vowel"
    case ping = "Ping"
    case riverside = "Riverside.fm"
    case doxy = "Doxy.me"
    case tuple = "Tuple"
    case around = "Around"
    case daily = "Daily.co"
    case cal = "Cal.com"
    case wire = "Wire"

    // Tier 4 — regional / niche
    case lark = "Lark"
    case dingtalk = "DingTalk"
    case tencentMeeting = "Tencent Meeting"
    case zoho = "Zoho Meeting"
    case freeConferenceCall = "FreeConferenceCall"
    case joinMe = "Join.me"
    case pexip = "Pexip"
    case vidyo = "Vidyo"
    case blackboard = "Blackboard Collaborate"
    case bigbluebutton = "BigBlueButton"
    case eye = "Eyeson"
    case clickmeeting = "ClickMeeting"
    case crowdcast = "Crowdcast"
    case livewebinar = "LiveWebinar"
    case meetfox = "MeetFox"

    case other = "Meeting"

    var id: String { rawValue }
}

struct MeetingLink {
    let url: URL
    let service: MeetingService
}

enum MeetingLinkDetector {

    private static let patterns: [(service: MeetingService, regex: String)] = [
        // Tier 1
        (.googleMeet,   #"https?://meet\.google\.com/[a-z\-]+"#),
        (.zoom,         #"https?://[\w.]*zoom\.(us|com)/[jw]/\d+"#),
        (.teams,        #"https?://teams\.microsoft\.com/l/meetup-join/[^\s]+"#),
        (.webex,        #"https?://[\w.]*webex\.com/[\w./\-]+"#),
        (.gotoMeeting,  #"https?://([\w.]*gotomeet\.me/[\w\-]+|[\w.]*goto\.(com|meeting)/[\w./\-]+)"#),
        (.bluejeans,    #"https?://[\w.]*bluejeans\.com/\d+"#),
        (.whereby,      #"https?://[\w.]*whereby\.com/[\w\-]+"#),

        // Tier 2
        (.chime,        #"https?://[\w.]*chime\.aws/\d+"#),
        (.jitsi,        #"https?://meet\.jit\.si/[\w\-]+"#),
        (.skype,        #"https?://join\.skype\.com/[\w]+"#),
        (.slack,        #"https?://[\w.]*slack\.com/[\w./\-]*huddle[^\s]*"#),
        (.discord,      #"https?://discord\.(gg|com/invite)/[\w]+"#),
        (.ringcentral,  #"https?://[\w.]*ringcentral\.com/[\w./\-]*"#),
        (.dialpad,      #"https?://[\w.]*dialpad\.com/[\w./\-]*"#),
        (.meet8x8,      #"https?://[\w.]*8x8\.vc/[\w./\-]+"#),
        (.vonage,       #"https?://[\w.]*vonage\.com/[\w./\-]*"#),
        (.lifesize,     #"https?://[\w.]*lifesize\.com/[\w./\-]+"#),
        (.starleaf,     #"https?://[\w.]*starleaf\.com/[\w./\-]+"#),
        (.facetime,     #"https?://facetime\.apple\.com/join[^\s]*"#),

        // Tier 3
        (.livestorm,    #"https?://[\w.]*livestorm\.(co|com)/[\w./\-]+"#),
        (.demio,        #"https?://[\w.]*demio\.com/[\w./\-]+"#),
        (.streamyard,   #"https?://[\w.]*streamyard\.com/[\w./\-]+"#),
        (.hopin,        #"https?://[\w.]*hopin\.(to|com)/[\w./\-]+"#),
        (.airmeet,      #"https?://[\w.]*airmeet\.com/[\w./\-]+"#),
        (.gather,       #"https?://[\w.]*gather\.town/[\w./\-]+"#),
        (.butter,       #"https?://[\w.]*butter\.us/[\w./\-]+"#),
        (.kumospace,    #"https?://[\w.]*kumospace\.com/[\w./\-]+"#),
        (.rally,        #"https?://[\w.]*rally\.video/[\w./\-]+"#),
        (.pop,          #"https?://[\w.]*pop\.com/[\w./\-]+"#),
        (.tandem,       #"https?://[\w.]*tandem\.chat/[\w./\-]+"#),
        (.vowel,        #"https?://[\w.]*vowel\.com/[\w./\-]+"#),
        (.ping,         #"https?://[\w.]*ping\.gg/[\w./\-]+"#),
        (.riverside,    #"https?://[\w.]*riverside\.fm/[\w./\-]+"#),
        (.doxy,         #"https?://[\w.]*doxy\.me/[\w./\-]+"#),
        (.tuple,        #"https?://[\w.]*tuple\.app/[\w./\-]+"#),
        (.around,       #"https?://[\w.]*around\.co/[\w./\-]+"#),
        (.daily,        #"https?://[\w.]*daily\.co/[\w./\-]+"#),
        (.cal,          #"https?://[\w.]*cal\.com/[\w./\-]+"#),
        (.wire,         #"https?://[\w.]*wire\.com/[\w./\-]+"#),

        // Tier 4
        (.lark,         #"https?://[\w.]*(?:lark|feishu)\.(?:com|cn)/[\w./\-]+"#),
        (.dingtalk,     #"https?://[\w.]*dingtalk\.com/[\w./\-]+"#),
        (.tencentMeeting, #"https?://[\w.]*(?:meeting\.tencent\.com|voovmeeting\.com)/[\w./\-]+"#),
        (.zoho,         #"https?://[\w.]*zoho\.com/meeting/[\w./\-]+"#),
        (.freeConferenceCall, #"https?://[\w.]*freeconferencecall\.com/[\w./\-]+"#),
        (.joinMe,       #"https?://[\w.]*join\.me/[\w\-]+"#),
        (.pexip,        #"https?://[\w.]*pexip\.com/[\w./\-]+"#),
        (.vidyo,        #"https?://[\w.]*vidyo\.com/[\w./\-]+"#),
        (.blackboard,   #"https?://[\w.]*blackboard\.com/[\w./\-]+"#),
        (.bigbluebutton, #"https?://[\w.]*[\w\-]+\.\w+/bigbluebutton/[\w./\-]+"#),
        (.eye,          #"https?://[\w.]*eyeson\.com/[\w./\-]+"#),
        (.clickmeeting, #"https?://[\w.]*clickmeeting\.com/[\w./\-]+"#),
        (.crowdcast,    #"https?://[\w.]*crowdcast\.io/[\w./\-]+"#),
        (.livewebinar,  #"https?://[\w.]*livewebinar\.com/[\w./\-]+"#),
        (.meetfox,      #"https?://[\w.]*meetfox\.com/[\w./\-]+"#),
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

    static func detect(location: String?, notes: String?, url: URL? = nil) -> MeetingLink? {
        if let link = detect(in: location) { return link }
        if let link = detect(in: notes) { return link }
        if let url, let link = detect(in: url.absoluteString) { return link }
        return nil
    }

    private static func detectGenericMeetingURL(in text: String) -> URL? {
        let meetingKeywords = ["join", "meeting", "conference", "call", "video", "webinar", "room"]
        let urlPattern = #"https?://[^\s<>"']+"#

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
