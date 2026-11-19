@testable import MatrixCore
import XCTest

final class DeliveriesTests: XCTestCase {
    private func status(_ fields: String) -> String {
        #"{"network":"whatsapp","m.relates_to":{"rel_type":"m.reference","event_id":"$sent"},\#(fields)}"#
    }

    func testADeliveryReportNamesItsMessage() {
        let parsed = SendStatus.parse(status(#""status":"SUCCESS","delivered_to_users":["@other:example.org"]"#))
        XCTAssertEqual(parsed, SendStatus(eventId: "$sent", isSuccess: true, isDelivered: true))
    }

    func testASuccessWithoutDeliveredUsersIsNotDelivered() {
        XCTAssertEqual(SendStatus.parse(status(#""status":"SUCCESS""#)), SendStatus(eventId: "$sent", isSuccess: true, isDelivered: false))
        XCTAssertEqual(SendStatus.parse(status(#""status":"SUCCESS","delivered_to_users":null"#))?.isDelivered, false)
        XCTAssertEqual(SendStatus.parse(status(#""status":"SUCCESS","delivered_to_users":[]"#))?.isDelivered, false)
        XCTAssertEqual(SendStatus.parse(status(#""status":"SUCCESS","delivered_to_users":"@other:example.org""#))?.isDelivered, false)
    }

    func testAFailureIsNoSuccess() {
        for word in ["PENDING", "FAIL_RETRIABLE", "FAIL_PERMANENT"] {
            XCTAssertEqual(SendStatus.parse(status(#""status":"\#(word)""#))?.isSuccess, false, word)
        }
    }

    func testContentThatNamesNoMessageIsNothing() {
        XCTAssertNil(SendStatus.parse(""))
        XCTAssertNil(SendStatus.parse("[]"))
        XCTAssertNil(SendStatus.parse(#"{"status":"SUCCESS","delivered_to_users":["@other:example.org"]}"#))
        XCTAssertNil(SendStatus.parse(#"{"status":"SUCCESS","m.relates_to":{"rel_type":"m.annotation","event_id":"$sent"}}"#))
        XCTAssertNil(SendStatus.parse(#"{"status":"SUCCESS","m.relates_to":{"rel_type":"m.reference","event_id":""}}"#))
    }

    func testOnlyAnotherMembersDeliveredSuccessIsRecorded() {
        let deliveries = Deliveries(file: nil)
        let delivered = status(#""status":"SUCCESS","delivered_to_users":["@other:example.org"]"#)
        let me = "@me:example.org", bot = "@bot:example.org"
        XCTAssertFalse(deliveries.record(contentJson: delivered, sender: me, timestamp: 1, me: me), "an own event is ignored")
        XCTAssertTrue(deliveries.record(contentJson: status(#""status":"SUCCESS""#), sender: bot, timestamp: 2, me: me), "its receipt is news")
        XCTAssertTrue(deliveries.record(contentJson: status(#""status":"FAIL_PERMANENT","delivered_to_users":["@other:example.org"]"#),
                                        sender: bot, timestamp: 3, me: me))
        XCTAssertFalse(deliveries.contains("$sent"))
        XCTAssertTrue(deliveries.record(contentJson: delivered, sender: bot, timestamp: 4, me: me))
        XCTAssertTrue(deliveries.contains("$sent"))
        XCTAssertFalse(deliveries.record(contentJson: delivered, sender: bot, timestamp: 4, me: me), "known already: no news")
    }

    func testAStatusEventsOwnReceiptIsNoReading() {
        let deliveries = Deliveries(file: nil)
        XCTAssertFalse(deliveries.isReport("@bot:example.org", 40))
        _ = deliveries.record(contentJson: status(#""status":"SUCCESS""#), sender: "@bot:example.org", timestamp: 40, me: "@me:example.org")
        XCTAssertTrue(deliveries.isReport("@bot:example.org", 40))
        XCTAssertFalse(deliveries.isReport("@bot:example.org", 41), "a receipt at another time is a reading")
        XCTAssertFalse(deliveries.isReport("@other:example.org", 40))
        XCTAssertFalse(deliveries.isReport("@bot:example.org", nil))
    }

    func testConcurrentReportsSurviveReopening() {
        let file = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: file) }
        let deliveries = Deliveries(file: file)
        DispatchQueue.concurrentPerform(iterations: 128) { number in
            let content = #"{"status":"SUCCESS","delivered_to_users":["user"],"m.relates_to":{"rel_type":"m.reference","event_id":"$\#(number)"}}"#
            _ = deliveries.record(contentJson: content, sender: "bridge", timestamp: UInt64(number), me: "me")
        }
        let reopened = Deliveries(file: file)
        for number in 0..<128 {
            XCTAssertTrue(reopened.contains("$\(number)"))
        }
    }

    func testDeliveriesAreKeptInTheirFileUpToTheLimit() throws {
        let file = FileManager.default.temporaryDirectory.appendingPathComponent("deliveries-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: file) }
        let deliveries = Deliveries(file: file)
        for number in 0..<(Deliveries.limit + 5) {
            let content = #"{"status":"SUCCESS","delivered_to_users":["@other:example.org"],"m.relates_to":{"rel_type":"m.reference","event_id":"$\#(number)"}}"#
            XCTAssertTrue(deliveries.record(contentJson: content, sender: "@bot:example.org", timestamp: UInt64(number), me: "@me:example.org"))
        }
        let again = Deliveries(file: file)
        XCTAssertFalse(again.contains("$4"), "the oldest are dropped")
        XCTAssertTrue(again.contains("$5"))
        XCTAssertTrue(again.contains("$\(Deliveries.limit + 4)"))
        XCTAssertFalse(again.isReport("@bot:example.org", 4))
        XCTAssertTrue(again.isReport("@bot:example.org", 5))
    }

    /// One person's message becomes delivered when another member reports it, as a bridge does
    /// with `delivered_to_users`, and not before.
    func testAMessageIsDeliveredWhenItsStatusEventSaysSo() async throws {
        let env = ProcessInfo.processInfo.environment
        guard let user = env["MATRIX_TEST_USER"], let password = env["MATRIX_TEST_PASSWORD"], !password.isEmpty,
              let user2 = env["MATRIX_TEST_USER2"], let password2 = env["MATRIX_TEST_PASSWORD2"], !password2.isEmpty else {
            throw XCTSkip("two test users are needed (MATRIX_TEST_USER2 and MATRIX_TEST_PASSWORD2)")
        }
        let homeserver = env["MATRIX_TEST_HOMESERVER"] ?? "matrix.org"
        let sender = try await testAccount(homeserver, user, password)
        let reporter = try await testAccount(homeserver, user2, password2)
        let rooms = try await sender.rooms()
        let roomId = try XCTUnwrap(rooms.first { $0.name == "Multiplexer two-person test" }?.id)
        _ = try await reporter.rooms()

        let text = "Delivery \(UUID().uuidString)"
        try await sender.sendAndWait(roomId: roomId, text: text)
        // the chat can show the sent message a moment after the send returns.
        func sent() async throws -> Message {
            let start = Date()
            while true {
                if let found = try await sender.messages(roomId: roomId, limit: 20).last(where: { $0.body == text }) { return found }
                if Date().timeIntervalSince(start) > 15 { return try XCTUnwrap(nil as Message?, "the sent message did not show within 15 s") }
                try await Task.sleep(nanoseconds: 300_000_000)
            }
        }
        var message = try await sent()
        XCTAssertTrue(message.eventId.hasPrefix("$"))
        XCTAssertFalse(message.isDelivered, "no report yet")
        // the list's preview follows the sync: its newest message can lag the chat's by a moment.
        func preview(_ wanted: String) async throws -> String? {
            let limit = Date().addingTimeInterval(15)
            var status: String?
            repeat {
                status = try await sender.rooms().first { $0.id == roomId }?.lastStatus
                if status == wanted { break }
                try await Task.sleep(nanoseconds: 300_000_000)
            } while Date() < limit
            return status
        }
        let before = try await preview("sent")
        XCTAssertEqual(before, "sent")

        // an own report counts for nothing.
        _ = try await sender.sendDeliveredStatus(roomId: roomId, eventId: message.eventId)
        _ = try await reporter.sendDeliveredStatus(roomId: roomId, eventId: message.eventId)
        let deadline = Date().addingTimeInterval(20)
        while Date() < deadline, !message.isDelivered {
            try await Task.sleep(nanoseconds: 300_000_000)
            message = try await sent()
        }
        XCTAssertTrue(message.isDelivered, "the other member's report marks the message")
        // the sdk counts the report as its sender having read the chat; that is no reading.
        try await Task.sleep(nanoseconds: 3_000_000_000)
        message = try await sent()
        XCTAssertEqual(message.readBy, [], "a delivery report does not make the message seen")
        XCTAssertTrue(sender.deliveries.contains(message.eventId))
        let after = try await preview("delivered")
        XCTAssertEqual(after, "delivered")
    }
}
