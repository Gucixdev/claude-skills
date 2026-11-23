import { test, expect } from 'claude-code/testing';
import { blockText, nextOpen, parseCmd, seconds, status, todoPath } from './loop.ts';

test('nextOpen skips comments, done, blocked, [x] and [?] lines', () => {
  const todo = '# todo\n\n1. old -> zrobione\n[x] ticked\n[?] waits (questions.md)\nthing with [?] inside\nblocked on hardware\nreal next\nlater';
  expect(nextOpen(todo)).toBe('real next');
  expect(nextOpen('# only\n[x] a\n')).toBeUndefined();
});

test('seconds and parseCmd', () => {
  expect(seconds('90m')).toBe(5400);
  expect(seconds('0m')).toBeUndefined();
  expect(seconds('x')).toBeUndefined();
  expect(parseCmd('on 2h')).toEqual({ kind: 'on', secs: 7200 });
  expect(parseCmd('on')).toEqual({ kind: 'on', secs: 28800 });
  expect(parseCmd('')).toEqual({ kind: 'status' });
  expect(parseCmd('off')).toEqual({ kind: 'off' });
  expect(parseCmd('on zz').kind).toBe('bad');
  expect(parseCmd('frob').kind).toBe('bad');
});

test('status and the text handed back', () => {
  expect(status(undefined, 0, 300)).toBe('afkloop: off');
  expect(status({ until: 60000, count: 2 }, 0, 300)).toBe('afkloop: on, 1 min left, 2 of 300 stops blocked');
  expect(status({ until: 0, count: 2 }, 5, 300)).toBe('afkloop: off');
  expect(blockText('do it', 1, 300, 5)).toContain('Next open line of todo.md:\n  do it');
});

test('todoPath: option, then CLAUDE_CONFIG, then home', () => {
  expect(todoPath('/x/todo.md', '/c', '/h')).toBe('/x/todo.md');
  expect(todoPath('', '/c', '/h')).toBe('/c/todo.md');
  expect(todoPath(undefined, undefined, '/h')).toBe('/h/.claude-config/todo.md');
});
