/* Exercises what RV32I has: arithmetic, shifts, comparisons signed and unsigned, branches, byte/half/word loads and stores.
 * Operands are volatile so the compiler cannot fold them away; each check returns its own number on failure. */
typedef unsigned int u32;
typedef int s32;

static volatile u32 ua = 0xfffffff0u, ub = 7;
static volatile s32 sa = -16, sb = 7;
static volatile unsigned char buf[8];

int main(void) {
	u32 u = ua, v = ub;
	s32 s = sa, t = sb;
	volatile unsigned short *h = (volatile unsigned short *)buf;
	volatile u32 *w = (volatile u32 *)buf;
	if (u + v != 0xfffffff7u) return 1;
	if (u - v != 0xffffffe9u) return 2;
	if ((u ^ v) != 0xfffffff7u || (u & v) != 0 || (u | v) != 0xfffffff7u) return 3;
	if ((u >> 4) != 0x0fffffffu) return 4;
	if ((s >> 2) != -4) return 5;
	if ((v << 28) != 0x70000000u) return 6;
	if (!(s < t) || (u < v) || !(u > v)) return 7;
	if ((s32)((u32)s * 1u) != -16) return 8;
	buf[0] = 0x80; buf[1] = 0x01; buf[2] = 0xff; buf[3] = 0x7f;
	if (*w != 0x7fff0180u) return 9;
	if ((s32)(signed char)buf[0] != -128) return 10;
	if (*h != 0x0180u) return 11;
	*h = 0xbeef;
	if (buf[0] != 0xef || buf[1] != 0xbe) return 12;
	{
		u32 n = 0, i;
		for (i = 0; i < 100; i++) n += (i & 1) ? i : (i >> 1);
		if (n != 2500u + 1225u) return 13;
	}
	return 0;
}
