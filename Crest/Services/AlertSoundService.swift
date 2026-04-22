import AVFoundation
import AppKit

@MainActor
final class AlertSoundService {
    static let shared = AlertSoundService()

    private var player: AVAudioPlayer?

    private init() {}

    func playMeetingAlert() {
        play(systemSoundNamed: "Funk")
    }

    func playPrayerOverlayAlert() {
        play(systemSoundNamed: "Glass")
    }

    private func play(systemSoundNamed name: String) {
        player?.stop()
        player = nil

        let url = URL(fileURLWithPath: "/System/Library/Sounds/\(name).aiff")
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.play()
        } catch {
            NSSound.beep()
        }
    }
}
