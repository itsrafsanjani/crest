import AppKit
import SwiftUI

final class PrayerEndingOverlayWindow: NSPanel {
    private let onDismissAction: () -> Void

    init(prayer: Prayer, prayerEndTime: Date,
         nextPrayer: Prayer?, nextPrayerStartTime: Date?,
         onDismiss: @escaping () -> Void) {
        self.onDismissAction = onDismiss

        let screen = NSScreen.main ?? NSScreen.screens[0]
        let frame = screen.frame

        super.init(
            contentRect: frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        self.level = .screenSaver
        self.isOpaque = false
        self.backgroundColor = .clear
        self.hasShadow = false
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.isMovable = false
        self.isMovableByWindowBackground = false
        self.hidesOnDeactivate = false

        let overlayView = PrayerEndingOverlayView(
            prayer: prayer,
            prayerEndTime: prayerEndTime,
            nextPrayer: nextPrayer,
            nextPrayerStartTime: nextPrayerStartTime,
            onDismiss: onDismiss
        )

        let hostingView = NSHostingView(rootView: overlayView)
        hostingView.frame = frame
        self.contentView = hostingView
    }

    func showFullscreen() {
        NSApp.activate(ignoringOtherApps: true)
        makeKeyAndOrderFront(nil)
    }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 { return }
        super.keyDown(with: event)
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}
