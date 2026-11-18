import Foundation
import UserNotifications

/// Old messages that arrive as new pushes. A bridge fills a chat it has just made with the
/// messages from before (up to 50), each sent to the server now with its original time, and the
/// server pushes every one. iOS lets an extension change a notification, not drop it, so an old
/// message is made quiet (no sound, no banner, no screen wake: it only lies in Notification Center),
/// and the quiet ones before it in the same chat are removed, so a chat's history leaves one
/// entry, not fifty. A message that is news keeps its alert.
enum NotificationAge {
    /// a push comes within seconds of its message; this is far past any delay of a bridge or a server.
    static let historyAfter: TimeInterval = 10 * 60
    static let mark = "mux_history"

    /// `sentAt`: the message's time in milliseconds since 1970; 0 (not known) is never history.
    static func isHistory(sentAt: UInt64, now: Date) -> Bool {
        sentAt > 0 && now.timeIntervalSince1970 - Double(sentAt) / 1000 > historyAfter
    }

    static func quiet(_ content: UNMutableNotificationContent) {
        content.sound = nil
        content.interruptionLevel = .passive
        content.relevanceScore = 0
        content.userInfo[mark] = true
    }

    /// The quiet notifications already delivered for `roomId`, which a newer one replaces.
    static func earlier(_ requests: [UNNotificationRequest], roomId: String) -> [String] {
        guard !roomId.isEmpty else { return [] }
        return requests.compactMap { request in
            let info = request.content.userInfo
            return info[mark] as? Bool == true && info["room_id"] as? String == roomId ? request.identifier : nil
        }
    }

    static func removeEarlier(roomId: String) async {
        let center = UNUserNotificationCenter.current()
        let ids = earlier(await center.deliveredNotifications().map(\.request), roomId: roomId)
        if !ids.isEmpty { center.removeDeliveredNotifications(withIdentifiers: ids) }
    }
}
