import XCTest
@testable import Crest

final class MeetingLinkDetectorTests: XCTestCase {

    // MARK: - Tier 1 services

    func test_detectsGoogleMeet() {
        let link = MeetingLinkDetector.detect(in: "Join: https://meet.google.com/abc-defg-hij later today")
        XCTAssertEqual(link?.service, .googleMeet)
        XCTAssertEqual(link?.url.absoluteString, "https://meet.google.com/abc-defg-hij")
    }

    func test_detectsZoom() {
        let link = MeetingLinkDetector.detect(in: "Standup: https://us02web.zoom.us/j/12345678901")
        XCTAssertEqual(link?.service, .zoom)
    }

    func test_detectsTeams() {
        let link = MeetingLinkDetector.detect(in: "https://teams.microsoft.com/l/meetup-join/19%3ameeting_xxx")
        XCTAssertEqual(link?.service, .teams)
    }

    func test_detectsWebex() {
        let link = MeetingLinkDetector.detect(in: "https://company.webex.com/meet/jdoe")
        XCTAssertEqual(link?.service, .webex)
    }

    func test_detectsWhereby() {
        let link = MeetingLinkDetector.detect(in: "Click https://whereby.com/standup-room")
        XCTAssertEqual(link?.service, .whereby)
    }

    func test_detectsJitsi() {
        let link = MeetingLinkDetector.detect(in: "https://meet.jit.si/MyDailyStandup")
        XCTAssertEqual(link?.service, .jitsi)
    }

    // MARK: - Negative cases

    func test_returnsNilForEmptyString() {
        XCTAssertNil(MeetingLinkDetector.detect(in: ""))
    }

    func test_returnsNilForNil() {
        XCTAssertNil(MeetingLinkDetector.detect(in: nil))
    }

    func test_returnsNilForPlainURLWithoutMeetingKeywords() {
        // github.com is not a meeting service and has no meeting keyword in path
        XCTAssertNil(MeetingLinkDetector.detect(in: "See https://github.com/anthropics/claude-code"))
    }

    func test_returnsNilForTextWithoutURL() {
        XCTAssertNil(MeetingLinkDetector.detect(in: "Lunch in the kitchen"))
    }

    // MARK: - Detection ordering

    func test_picksFirstKnownServiceWhenMultiplePresent() {
        // Both Zoom and Meet appear; the order is determined by the patterns array,
        // which lists Google Meet before Zoom. So Meet wins regardless of text order.
        let text = """
        Backup: https://us02web.zoom.us/j/99999999999
        Primary: https://meet.google.com/abc-defg-hij
        """
        let link = MeetingLinkDetector.detect(in: text)
        XCTAssertEqual(link?.service, .googleMeet)
    }

    // MARK: - Generic-URL fallback

    func test_fallsBackToGenericMeetingURLWhenKeywordPresent() {
        let link = MeetingLinkDetector.detect(in: "Join here: https://example.com/conference/12345")
        XCTAssertEqual(link?.service, .other)
        XCTAssertEqual(link?.url.absoluteString, "https://example.com/conference/12345")
    }

    func test_genericFallbackRequiresMeetingKeyword() {
        // No meeting keyword in URL — should not match generic fallback.
        XCTAssertNil(MeetingLinkDetector.detect(in: "Docs at https://example.com/docs/page"))
    }

    // MARK: - Multi-source variant

    func test_detectMultiSource_prefersLocationOverNotes() {
        let link = MeetingLinkDetector.detect(
            location: "https://meet.google.com/aaa-bbbb-ccc",
            notes: "https://us02web.zoom.us/j/12345678901"
        )
        XCTAssertEqual(link?.service, .googleMeet)
    }

    func test_detectMultiSource_fallsBackToNotesWhenLocationEmpty() {
        let link = MeetingLinkDetector.detect(
            location: nil,
            notes: "Dial in: https://us02web.zoom.us/j/12345678901"
        )
        XCTAssertEqual(link?.service, .zoom)
    }

    func test_detectMultiSource_fallsBackToURL() {
        let link = MeetingLinkDetector.detect(
            location: nil,
            notes: nil,
            url: URL(string: "https://meet.google.com/xxx-yyyy-zzz")
        )
        XCTAssertEqual(link?.service, .googleMeet)
    }
}
