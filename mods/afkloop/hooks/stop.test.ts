import { expect, test } from 'claude-code/testing';

const STOP = { session_id: 's', transcript_path: '/t', cwd: '/', hook_event_name: 'Stop', stop_hook_active: false } as const;

function world(on: any, mode: unknown, todo: string) {
  const sets: unknown[] = [];
  on('store.get', () => ({ value: mode }));
  on('store.set', (_: unknown, e: any) => { sets.push(e.value); return { value: undefined }; });
  on('store.delete', () => ({ value: undefined }));
  on('fs.read', () => ({ value: todo }));
  on('env.get', () => ({ value: undefined }));
  on('ui.status', () => ({ value: undefined }));
  on('classic.Stop', () => ({}));
  return sets;
}

test('on: a stop is blocked with the next open line and the count goes up', async ($, on) => {
  const sets = world(on, { until: Date.now() + 3600_000, count: 4 }, '[x] done one\n[?] waits\nreal next\n');
  const r: any = await $.classic.Stop(STOP);
  expect(r.block).toContain('real next');
  expect(r.block).not.toContain('waits');
  expect(JSON.stringify(sets)).toContain('"count":5');
});

test('off, expired, nothing open and the brake let the stop through', async ($, on) => {
  world(on, undefined, 'a\n');
  expect(((await $.classic.Stop(STOP)) as any).block).toBeUndefined();
});

test('nothing open: the stop is fine even when on', async ($, on) => {
  world(on, { until: Date.now() + 3600_000, count: 0 }, '[x] all ticked\n');
  expect(((await $.classic.Stop(STOP)) as any).block).toBeUndefined();
});

test('the brake: at max the mode ends and the stop goes through', async ($, on) => {
  world(on, { until: Date.now() + 3600_000, count: 300 }, 'open\n');
  expect(((await $.classic.Stop(STOP)) as any).block).toBeUndefined();
});
