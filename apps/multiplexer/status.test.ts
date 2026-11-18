import { expect, mock, test } from 'bun:test';

mock.module('@exact/clipboard', () => ({ ClipboardItem: class {}, write: async () => {} }));
mock.module('@exact/notifications', () => ({
  clearAppBadge: async () => {}, closeNotification: async () => {}, notificationStatus: async () => ({}),
  setAppBadge: async () => {}, showNotification: async () => {},
}));
const { statusOf } = await import('./app.ts');
const own = { isOwn: true, state: 'sent', readers: [] as { name: string; time: number }[], isDelivered: false };
const ana = { name: 'Ana', time: 2000 }, ben = { name: 'Ben', time: 3000 };

test('an own message is sent with one tick until its delivery or a reader is known', () => {
  expect(statusOf(own, false)).toEqual({ status: 'Sent', statusTime: 0, ticks: 1 });
  expect(statusOf({ ...own, isDelivered: undefined }, false)).toEqual({ status: 'Sent', statusTime: 0, ticks: 1 });
});

test('a delivered own message says so with two ticks', () => {
  expect(statusOf({ ...own, isDelivered: true }, false)).toEqual({ status: 'Delivered', statusTime: 0, ticks: 2 });
  expect(statusOf({ ...own, isDelivered: true }, true)).toEqual({ status: 'Delivered', statusTime: 0, ticks: 2 });
});

test('a read own message is seen with the read ticks, delivered or not', () => {
  expect(statusOf({ ...own, readers: [ana] }, false)).toEqual({ status: 'Seen', statusTime: 2000, ticks: 3 });
  expect(statusOf({ ...own, isDelivered: true, readers: [ana, ben] }, false)).toEqual({ status: 'Seen', statusTime: 3000, ticks: 3 });
  expect(statusOf({ ...own, readers: [ana, ben] }, true)).toEqual({ status: 'Seen by Ana and Ben', statusTime: 0, ticks: 3 });
});

test('a message on its way or failed has no status and no ticks', () => {
  expect(statusOf({ ...own, state: 'sending', isDelivered: true }, false)).toEqual({ status: '', statusTime: 0, ticks: 0 });
  expect(statusOf({ ...own, state: 'failed' }, false)).toEqual({ status: '', statusTime: 0, ticks: 0 });
});

test("another person's message never has ticks", () => {
  expect(statusOf({ ...own, isOwn: false, isDelivered: true }, false)).toEqual({ status: '', statusTime: 0, ticks: 0 });
  expect(statusOf({ ...own, isOwn: false, readers: [ana] }, true)).toEqual({ status: 'Seen by Ana', statusTime: 0, ticks: 0 });
});
