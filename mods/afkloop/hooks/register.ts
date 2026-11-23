import type { Register } from 'claude-code';
import { blockText, nextOpen, parseCmd, status, todoPath, type Mode } from './loop.ts';

const KEY = 'mode';

export const register: Register = (on, options) => {
  const max = Number(options.max ?? 300) || 300;

  on('session.start', async ($, e, next) => {
    await $.command.register({ name: 'afkloop', description: 'Keep working while away: on [90m|8h] | off | status' });
    return next(e);
  });

  on('command.run', { command: 'afkloop' }, async ($, e) => {
    const cmd = parseCmd(e.args);
    const now = Date.now();
    if (cmd.kind === 'bad') return { text: `afkloop: ${cmd.why}` };
    if (cmd.kind === 'on') await $.store.set(KEY, { until: now + cmd.secs * 1000, count: 0 } satisfies Mode);
    if (cmd.kind === 'off') await $.store.delete(KEY);
    const mode = (await $.store.get(KEY)) as Mode;
    const text = status(mode, now, max);
    $.ui.status(mode && mode.until > now ? text : undefined);
    return { text };
  });

  on('classic.Stop', async ($, e, next) => {
    const mode = (await $.store.get(KEY)) as Mode;
    const now = Date.now();
    if (!mode || mode.until <= now) return next(e);
    if (mode.count >= max) {
      await $.store.delete(KEY);
      $.ui.status(undefined);
      return next(e); // the brake: a loop that made no progress stops itself
    }
    const path = todoPath(options.todo, await $.env.get('CLAUDE_CONFIG'), await $.env.get('HOME'));
    const todo = await $.fs.read(path).catch(() => '');
    const open = nextOpen(todo);
    if (!open) return next(e); // nothing open: stopping is fine
    await $.store.set(KEY, { until: mode.until, count: mode.count + 1 } satisfies Mode);
    $.ui.status(`afkloop ${mode.count + 1}/${max}`);
    return { ...(await next(e)), block: blockText(open, mode.count + 1, max, Math.ceil((mode.until - now) / 60000)) };
  });
};
