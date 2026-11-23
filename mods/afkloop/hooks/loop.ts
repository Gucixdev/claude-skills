// the pure part of afkloop: which todo line is open, what a /afkloop command means, the text handed back
export type Mode = { until: number; count: number } | undefined;

// open = not empty, not a comment, not done (zrobione / done), not blocked, not ticked ([x]), not waiting for an answer ([?])
export function nextOpen(todo: string): string | undefined {
  for (const line of todo.split('\n')) {
    if (/^\s*(#|$)/.test(line)) continue;
    if (/zrobione|[Dd]one|[Bb]locked|\[\?\]|^\[x\]/.test(line)) continue;
    return line.slice(0, 300);
  }
  return undefined;
}

const UNIT: Record<string, number> = { s: 1, m: 60, h: 3600, d: 86400 };
export function seconds(s: string): number | undefined {
  const m = /^(\d+)([smhd]?)$/.exec(s.trim());
  return m && Number(m[1]) > 0 ? Number(m[1]) * (UNIT[m[2] || 's'] ?? 1) : undefined;
}

export type Cmd = { kind: 'on'; secs: number } | { kind: 'off' } | { kind: 'status' } | { kind: 'bad'; why: string };
export function parseCmd(args: string): Cmd {
  const [w, d] = args.trim().split(/\s+/);
  if (!w || w === 'status') return { kind: 'status' };
  if (w === 'off') return { kind: 'off' };
  if (w === 'on') {
    const secs = d ? seconds(d) : 8 * 3600;
    return secs ? { kind: 'on', secs } : { kind: 'bad', why: `bad duration '${d}' (like 90m or 8h)` };
  }
  return { kind: 'bad', why: 'usage: /afkloop on [90m|8h] | off | status' };
}

export function blockText(next: string, count: number, max: number, minutesLeft: number): string {
  return `afkloop is on (${minutesLeft} min left, ${count} of ${max} stops blocked). He is away and wants work to continue: do real work, do not stop, do not ask.\n` +
    `Next open line of todo.md:\n  ${next}\nDo it (or the next one if this one is blocked: then add one line to questions.md), verify, commit, tick it in todo.md, continue.`;
}

export function status(mode: Mode, now: number, max: number): string {
  if (!mode || mode.until <= now) return 'afkloop: off';
  return `afkloop: on, ${Math.ceil((mode.until - now) / 60000)} min left, ${mode.count} of ${max} stops blocked`;
}

// where todo.md is: the option, else $CLAUDE_CONFIG/todo.md, else ~/.claude-config/todo.md
export function todoPath(option: unknown, claudeConfig: string | undefined, home: string | undefined): string {
  if (typeof option === 'string' && option) return option;
  if (claudeConfig) return `${claudeConfig}/todo.md`;
  return `${home ?? ''}/.claude-config/todo.md`;
}
