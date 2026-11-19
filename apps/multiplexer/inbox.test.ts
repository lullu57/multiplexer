import { expect, mock, test } from 'bun:test';

mock.module('@exact/clipboard', () => ({ ClipboardItem: class {}, write: async () => {} }));
mock.module('@exact/notifications', () => ({
  clearAppBadge: async () => {}, closeNotification: async () => {}, notificationStatus: async () => ({}),
  setAppBadge: async () => {}, showNotification: async () => {},
}));
const { answer } = await import('./app');

test('a large inbox keeps native row and pin order across batch boundaries', async () => {
  const rooms = Array.from({ length: 411 }, (_, i) => ({
    id: String(i), name: 'First Last', oneToOne: i !== 40, avatar: '', unread: 0, markedUnread: i === 40, reminder: 0,
  }));
  const native = {
    available: true, watch: () => {},
    later: async ({ op }: { op: string }) => op === 'readCopies' ? { text: '' } : {
      rooms, pinned: ['410', 'missing', '40'], networks: [], communities: [], unread: 0, archiveUnread: 0, lowPriorityUnread: 0, reminders: 0,
    },
  };
  const list = await answer('loadRoomsByRecency', ['owner', '', '', '', ''], {} as never, {} as never, native as never);
  expect(list.rooms.map((room) => room.id)).toEqual(rooms.map((room) => room.id));
  expect(list.rooms[40].initials).toBe('FL');
  expect(list.rooms[40]).not.toHaveProperty('oneToOne');
  expect(list.pinned).toEqual([
    { id: '410', name: 'First Last', shortName: 'First', initials: 'FL', avatar: '', unread: false },
    { id: '40', name: 'First Last', shortName: 'First Last', initials: 'FL', avatar: '', unread: true },
  ]);
});

test('an older inbox answer arriving last cannot reconcile reminders again', async () => {
  let resolveOlder!: (value: unknown) => void;
  const older = new Promise((resolve) => { resolveOlder = resolve; });
  let requests = 0;
  let reconciliations = 0;
  const empty = { rooms: [], pinned: [], networks: [], communities: [], unread: 0, archiveUnread: 0, lowPriorityUnread: 0, reminders: 0 };
  const native = {
    available: true, watch: () => {},
    later: async ({ op }: { op: string }) => op === 'readCopies' ? { text: '' } : (++requests === 1 ? older : empty),
  };
  const storage = { fs: { readFile: async () => { reconciliations++; return new TextEncoder().encode('{}'); } } };
  const load = () => answer('loadRoomsByRecency', ['owner', '', '', '', ''], {} as never, storage as never, native as never);
  const first = load();
  await load();
  resolveOlder(empty);
  await first;
  expect(reconciliations).toBe(1);
});
