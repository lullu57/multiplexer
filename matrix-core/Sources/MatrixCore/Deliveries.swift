import Foundation
#if canImport(MatrixRustSDK)
import MatrixRustSDK
#endif

/// What a bridge's `com.beeper.message_send_status` event says about one of this account's
/// messages: the message it is about, whether the network took it, and whether the network said
/// that it reached a recipient's device (`delivered_to_users` names at least one user). A bridge
/// that reports no delivery leaves that list out, so its messages stay "sent" until they are read.
struct SendStatus: Equatable {
    static let eventType = "com.beeper.message_send_status"
    var eventId: String
    var isSuccess: Bool
    var isDelivered: Bool

    /// Nil when the content is no json object or names no message.
    static func parse(_ contentJson: String) -> SendStatus? {
        guard let object = try? JSONSerialization.jsonObject(with: Data(contentJson.utf8)) as? [String: Any],
              let relation = object["m.relates_to"] as? [String: Any],
              relation["rel_type"] as? String == "m.reference",
              let eventId = relation["event_id"] as? String, !eventId.isEmpty else { return nil }
        let users = (object["delivered_to_users"] as? [Any])?.compactMap { $0 as? String }.filter { !$0.isEmpty } ?? []
        return SendStatus(eventId: eventId, isSuccess: object["status"] as? String == "SUCCESS", isDelivered: !users.isEmpty)
    }
}

/// The event ids of this account's messages that a bridge reported as delivered, the newest 2000,
/// kept in the account's store folder so a chat opened after a launch still shows them. A status
/// event comes only by sync while its chat is open (`MatrixAccount.openTimeline`): one that came
/// while the chat was closed is not known here, and its message stays "sent" until it is read.
///
/// Also the status events themselves, by sender and time (`reports`). The sdk counts any event a
/// member sends as that member having read the chat up to it, so a status event made its sender
/// a reader of the message it reports (seen 2026-11-18: the message said "Seen" a moment after its
/// delivery report). A read receipt with a status event's sender and time is that event's, not a
/// reading (`isReport`).
final class Deliveries: @unchecked Sendable {
    static let limit = 2000
    private struct Kept: Codable {
        var delivered: [String] = []
        var reports: [String] = []
    }

    private let file: URL?
    private let lock = NSLock()
    /// The oldest first, so the cap drops the oldest.
    private var kept: Kept
    private var ids: Set<String>
    private var reports: Set<String>

    /// `file`: where they are kept; nil keeps them in memory only.
    init(file: URL?) {
        self.file = file
        let data = file.flatMap { try? Data(contentsOf: $0) }
        let read = data.flatMap { try? JSONDecoder().decode(Kept.self, from: $0) } ?? Kept()
        kept = Kept(delivered: Array(read.delivered.suffix(Self.limit)), reports: Array(read.reports.suffix(Self.limit)))
        ids = Set(kept.delivered)
        reports = Set(kept.reports)
    }

    func contains(_ eventId: String) -> Bool { lock.withLock { ids.contains(eventId) } }

    /// Whether a read receipt of `userId` at `timestamp` is a status event's own, not a reading.
    func isReport(_ userId: String, _ timestamp: UInt64?) -> Bool {
        guard let timestamp else { return false }
        return lock.withLock { reports.contains(Self.report(userId, timestamp)) }
    }

    private static func report(_ sender: String, _ timestamp: UInt64) -> String { "\(sender) \(timestamp)" }

    /// Records what a status event says; true when it changes what a chat shows: a message is now
    /// delivered, or a receipt is now known as the event's own. An event from `me` is ignored: only
    /// another member (the bridge) reports a delivery.
    func record(contentJson: String, sender: String, timestamp: UInt64, me: String) -> Bool {
        guard sender != me, let status = SendStatus.parse(contentJson) else { return false }
        let delivered = status.isSuccess && status.isDelivered ? status.eventId : nil
        let saved: Kept? = lock.withLock {
            let report = Self.report(sender, timestamp)
            let news = [reports.insert(report).inserted, delivered.map { ids.insert($0).inserted } ?? false]
            guard news.contains(true) else { return nil }
            if news[0] { kept.reports.append(report) }
            if news[1], let delivered { kept.delivered.append(delivered) }
            if kept.reports.count > Self.limit {
                for old in kept.reports.prefix(kept.reports.count - Self.limit) { reports.remove(old) }
                kept.reports.removeFirst(kept.reports.count - Self.limit)
            }
            if kept.delivered.count > Self.limit {
                for old in kept.delivered.prefix(kept.delivered.count - Self.limit) { ids.remove(old) }
                kept.delivered.removeFirst(kept.delivered.count - Self.limit)
            }
            return kept
        }
        guard let saved else { return false }
        if let file, let data = try? JSONEncoder().encode(saved) { try? data.write(to: file, options: .atomic) }
        return true
    }
}

/// Hears a room's status events from the sync and hands each to `handler`.
final class SendStatusListener: RoomMessageLikeEventsListener, @unchecked Sendable {
    private let handler: @Sendable (RoomMessageLikeEvent) -> Void
    init(_ handler: @escaping @Sendable (RoomMessageLikeEvent) -> Void) { self.handler = handler }
    func onEvent(event: RoomMessageLikeEvent) { handler(event) }
}

extension MatrixAccount {
    /// Watches a room's status events while its chat is open: a delivery marks its message
    /// (`Message.isDelivered`) and tells the chat and the list.
    func watchDeliveries(_ room: Room, roomId: String) -> TaskHandle {
        let me = (try? client.userId()) ?? ""
        return room.subscribeToMessageLikeEvents(
            eventType: messageLikeEventTypeFromString(s: SendStatus.eventType),
            listener: SendStatusListener { [weak self] event in
                guard let self, self.deliveries.record(contentJson: event.contentJson, sender: event.sender, timestamp: UInt64(event.timestamp), me: me) else { return }
                self.notify(.room(roomId))
                self.notify(.rooms)
            })
    }

    /// for tests only: reports `eventId` as delivered to this account, as a bridge does.
    func sendDeliveredStatus(roomId: String, eventId: String, timeout: TimeInterval = 120) async throws -> String {
        let target = try await room(roomId, timeout: timeout)
        let content = try JSONSerialization.data(withJSONObject: [
            "status": "SUCCESS", "network": "",
            "m.relates_to": ["rel_type": "m.reference", "event_id": eventId],
            "delivered_to_users": [(try? client.userId()) ?? ""],
        ] as [String: Any])
        return try await target.sendRaw(eventType: SendStatus.eventType, content: String(decoding: content, as: UTF8.self))
    }
}
