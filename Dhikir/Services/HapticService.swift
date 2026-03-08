import Foundation
#if os(iOS)
import UIKit
#endif

enum HapticStyle {
    case light, medium, success
}

func triggerHaptic(_ style: HapticStyle) {
    #if os(iOS)
    switch style {
    case .light:
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    case .medium:
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    case .success:
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    #endif
}
