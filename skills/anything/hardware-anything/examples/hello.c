/* Smallest program for rv32-run: prints a line to the UART, computes something, returns 0 when the result is right. */
#define UART ((volatile unsigned char *)0x10000000)

static void puts_(const char *s) {
	while (*s) *UART = (unsigned char)*s++;
}

int main(void) {
	unsigned a = 1, b = 1, i;
	for (i = 0; i < 10; i++) { unsigned t = a + b; a = b; b = t; }
	puts_("hello from rv32i\n");
	return b == 144 ? 0 : 1;	/* fib: the 12th number */
}
