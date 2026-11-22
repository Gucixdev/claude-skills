/* iss - a small RV32I instruction-set simulator: the reference model a hardware core is checked against.
 * Runs a flat binary loaded at 0x80000000 on the same memory map as QEMU's "virt" board (UART 0x10000000,
 * finisher 0x100000), so rv32-run -i can compare it with QEMU. One function, step(), is the whole CPU:
 * a hardware design is correct when it retires the same instructions with the same register writes.
 * usage: iss [-t] prog.bin     -t prints one line per retired instruction: pc insn rd=value
 * exit status = the program's (0 pass), 2 on trap (illegal instruction, bad address). */
#include <stdio.h>
#include <stdlib.h>

typedef unsigned int u32;
typedef int s32;

#define RAM_BASE 0x80000000u
#define RAM_SIZE 0x100000u
#define UART 0x10000000u
#define FINISH 0x100000u

static unsigned char ram[RAM_SIZE];
static u32 x[32], pc = RAM_BASE;
static int trace;

static void trap(const char *why, u32 a) {
	fprintf(stderr, "iss: trap at pc=%08x: %s (%08x)\n", pc, why, a);
	exit(2);
}

static unsigned char *at(u32 a, u32 n) {
	if (a < RAM_BASE || a - RAM_BASE > RAM_SIZE - n) trap("bad address", a);
	return ram + (a - RAM_BASE);
}

static u32 load(u32 a, int n, int sign) {
	unsigned char *p = at(a, (u32)n);
	u32 v = 0;
	int i;
	for (i = n - 1; i >= 0; i--) v = (v << 8) | p[i];
	if (sign && n < 4 && (v & (1u << (8 * n - 1)))) v |= ~0u << (8 * n);
	return v;
}

static void store(u32 a, u32 v, int n) {
	unsigned char *p;
	int i;
	if (a == UART) { putchar((int)(v & 0xff)); return; }
	if (a == FINISH) {
		fflush(stdout);
		exit((v & 0xffff) == 0x5555u ? 0 : (int)(v >> 16));
	}
	p = at(a, (u32)n);
	for (i = 0; i < n; i++) { p[i] = (unsigned char)v; v >>= 8; }
}

static void step(void) {
	u32 i = load(pc, 4, 0), next = pc + 4, a = x[(i >> 15) & 31], b = x[(i >> 20) & 31], r = 0;
	u32 rd = (i >> 7) & 31, f3 = (i >> 12) & 7, f7 = i >> 25;
	s32 ii = (s32)i >> 20;
	s32 is = (s32)(i & 0xfe000000u) >> 20 | (s32)((i >> 7) & 31);
	s32 ib = (s32)(i & 0x80000000u) >> 19 | (s32)((i & 0x80) << 4) | (s32)((i >> 20) & 0x7e0) | (s32)((i >> 7) & 0x1e);
	s32 ij = (s32)(i & 0x80000000u) >> 11 | (s32)(i & 0xff000) | (s32)((i >> 9) & 0x800) | (s32)((i >> 20) & 0x7fe);
	int w = 1, take = 0;

	switch (i & 0x7f) {
	case 0x37: r = i & 0xfffff000u; break;
	case 0x17: r = pc + (i & 0xfffff000u); break;
	case 0x6f: r = next; next = pc + (u32)ij; break;
	case 0x67: r = next; next = (a + (u32)ii) & ~1u; break;
	case 0x63:
		w = 0;
		switch (f3) {
		case 0: take = a == b; break;
		case 1: take = a != b; break;
		case 4: take = (s32)a < (s32)b; break;
		case 5: take = (s32)a >= (s32)b; break;
		case 6: take = a < b; break;
		case 7: take = a >= b; break;
		default: trap("illegal branch", i);
		}
		if (take) next = pc + (u32)ib;
		break;
	case 0x03:
		switch (f3) {
		case 0: r = load(a + (u32)ii, 1, 1); break;
		case 1: r = load(a + (u32)ii, 2, 1); break;
		case 2: r = load(a + (u32)ii, 4, 0); break;
		case 4: r = load(a + (u32)ii, 1, 0); break;
		case 5: r = load(a + (u32)ii, 2, 0); break;
		default: trap("illegal load", i);
		}
		break;
	case 0x23:
		w = 0;
		if (f3 > 2) trap("illegal store", i);
		store(a + (u32)is, b, 1 << f3);
		break;
	case 0x13:
	case 0x33: {
		u32 y = (i & 0x7f) == 0x13 ? (u32)ii : b;
		int reg = (i & 0x7f) == 0x33;
		switch (f3) {
		case 0: r = (reg && f7 == 0x20) ? a - y : a + y; break;
		case 1: r = a << (y & 31); break;
		case 2: r = (s32)a < (s32)y; break;
		case 3: r = a < y; break;
		case 4: r = a ^ y; break;
		case 5: r = (f7 == 0x20) ? (u32)((s32)a >> (y & 31)) : a >> (y & 31); break;
		case 6: r = a | y; break;
		default: r = a & y; break;
		}
		if (reg && f7 == 0x01) trap("M extension not implemented", i);
		break;
	}
	case 0x0f: w = 0; break;
	default: trap("illegal instruction", i);
	}
	if (w && rd) x[rd] = r;
	if (trace) printf("%08x %08x %s%u=%08x\n", pc, i, w && rd ? "x" : "-", w && rd ? rd : 0u, w && rd ? r : 0u);
	pc = next;
}

int main(int argc, char **argv) {
	FILE *f;
	size_t n;
	if (argc > 1 && argv[1][0] == '-' && argv[1][1] == 't') { trace = 1; argv++; argc--; }
	if (argc != 2) { fprintf(stderr, "usage: iss [-t] prog.bin\n"); return 2; }
	f = fopen(argv[1], "rb");
	if (!f) { perror(argv[1]); return 2; }
	n = fread(ram, 1, RAM_SIZE, f);
	fclose(f);
	if (n == 0) { fprintf(stderr, "iss: empty program\n"); return 2; }
	for (;;) step();
}
