import Foundation
import AVFoundation

@Observable
final class AudioService {
    static let shared = AudioService()

    private var audioPlayer: AVAudioPlayer?

    var isPlaying: Bool = false
    var currentTime: TimeInterval = 0
    var duration: TimeInterval = 0

    private init() {
        setupAudioSession()
    }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.allowAirPlay, .allowBluetoothA2DP]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            #if DEBUG
            print("Failed to setup audio session: \(error)")
            #endif
        }
    }

    func play(fileName: String) {
        guard let url = Bundle.main.url(
            forResource: fileName,
            withExtension: nil,
            subdirectory: "Audio"
        ) else {
            #if DEBUG
            print("Audio file not found: \(fileName)")
            #endif
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            isPlaying = true
            duration = audioPlayer?.duration ?? 0

            startTimeUpdates()
        } catch {
            #if DEBUG
            print("Failed to play audio: \(error)")
            #endif
        }
    }

    func pause() {
        audioPlayer?.pause()
        isPlaying = false
    }

    func resume() {
        audioPlayer?.play()
        isPlaying = true
    }

    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        currentTime = 0
    }

    func seek(to time: TimeInterval) {
        audioPlayer?.currentTime = time
        currentTime = time
    }

    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            resume()
        }
    }

    private func startTimeUpdates() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self, let player = self.audioPlayer else {
                timer.invalidate()
                return
            }

            self.currentTime = player.currentTime

            if !player.isPlaying && self.currentTime >= self.duration - 0.1 {
                self.isPlaying = false
                self.currentTime = 0
                timer.invalidate()
            }
        }
    }
}
