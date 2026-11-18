import { expect, test } from 'bun:test';
import { mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join, resolve } from 'node:path';

// compiles the extension's actual age rule and runs it: which messages are history, what quiet
// changes, and which delivered notifications a newer quiet one replaces.
test('an old message is quiet and replaces the earlier quiet ones of its chat only', () => {
  const directory = mkdtempSync(join(tmpdir(), 'mux-notification-age-'));
  const root = resolve(import.meta.dir, '..');
  try {
    writeFileSync(join(directory, 'Check.swift'), String.raw`
import Foundation
import UserNotifications
func request(_ id: String, room: String, history: Bool) -> UNNotificationRequest {
    let content = UNMutableNotificationContent()
    content.userInfo = ["room_id": room]
    if history { NotificationAge.quiet(content) }
    return UNNotificationRequest(identifier: id, content: content, trigger: nil)
}
@main struct Check {
    static func main() {
        let now = Date(timeIntervalSince1970: 2_000_000_000)
        let ms = { (secondsAgo: Double) in UInt64((now.timeIntervalSince1970 - secondsAgo) * 1000) }
        precondition(!NotificationAge.isHistory(sentAt: ms(5), now: now), "a message of now is news")
        precondition(!NotificationAge.isHistory(sentAt: ms(9 * 60), now: now), "a slow bridge's message is news")
        precondition(NotificationAge.isHistory(sentAt: ms(11 * 60), now: now), "an 11 minute old message is history")
        precondition(NotificationAge.isHistory(sentAt: ms(30 * 86_400), now: now))
        precondition(!NotificationAge.isHistory(sentAt: 0, now: now), "an unknown time is news")
        precondition(!NotificationAge.isHistory(sentAt: ms(-3600), now: now), "a clock ahead is news")

        let content = UNMutableNotificationContent()
        content.sound = .default
        content.userInfo = ["room_id": "!a:example.org", "exact": ["event": "notificationclick"]]
        NotificationAge.quiet(content)
        precondition(content.sound == nil && content.interruptionLevel == .passive)
        precondition(content.userInfo["exact"] != nil, "quiet keeps the chat destination")

        let delivered = [request("old-a-1", room: "!a:example.org", history: true),
                         request("news-a", room: "!a:example.org", history: false),
                         request("old-b", room: "!b:example.org", history: true),
                         request("old-a-2", room: "!a:example.org", history: true)]
        precondition(NotificationAge.earlier(delivered, roomId: "!a:example.org") == ["old-a-1", "old-a-2"])
        precondition(NotificationAge.earlier(delivered, roomId: "").isEmpty)
        print("notification age passed")
    }
}
`);
    const binary = join(directory, 'check');
    const compile = Bun.spawnSync(['xcrun', 'swiftc', '-parse-as-library', '-swift-version', '5', join(directory, 'Check.swift'),
      join(root, 'apps/multiplexer/extensions/notifications/NotificationAge.swift'), '-o', binary]);
    if (compile.exitCode !== 0) throw new Error(compile.stderr.toString());
    const run = Bun.spawnSync([binary]);
    if (run.exitCode !== 0) throw new Error(run.stderr.toString().split('\n').slice(0, 4).join('\n'));
    expect(run.stdout.toString()).toContain('notification age passed');
  } finally { rmSync(directory, { recursive: true, force: true }); }
}, 60_000);
