#include <stdio.h>
#include <strings.h>
#include <time.h>

int counters[3];
int width;
int line;
struct timespec delay;

void move(int disc, int a, int b)
{
	int d, s;

	nanosleep(&delay, NULL);

	d = b - line;
	if (d != 0) {
		if (d < 0)
			printf("\033[%dF", -d);
		else
			printf("\033[%dE", d);
		s = (width + 1) * counters[b];
		if (s > 0)
			printf("\033[%dC", s);
	}
	printf("|%-*d", width, disc);

	d = a - b;
	if (d < 0)
		printf("\033[%dF", -d);
	else
		printf("\033[%dE", d);
	s = (width + 1) * (counters[a] - 1);
	if (s > 0)
		printf("\033[%dC", s);
	printf("\033[K");

	fflush(stdout);

	line = a;
	counters[a]--;
	counters[b]++;
}

void sim(int n)
{
	unsigned int count = 0, t = 0, newt, max, disc;
	int p;

	max = (1 << n) - 1;
	p = n % 2 == 0 ? 1 : -1;

	for (;;) {
		newt = (t + p + 3) % 3;
		move(1, t, newt);
		t = newt;

		count++;

		if (count == max)
			break;

		disc = ffs(~count);
		if (disc % 2 == 0)
			move(disc, (t - p + 3) % 3, (t + p + 3) % 3);
		else
			move(disc, (t + p + 3) % 3, (t - p + 3) % 3);

		count++;
	}
}

void run(int n)
{
	counters[0] = n;
	counters[1] = 0;
	counters[2] = 0;
	line = 3;
	width = n < 10 ? 1 : 2;

	for (int j = n; j > 0; j--)
		printf("|%-*d", width, j);
	for (int i = 0; i < 3; i++)
		printf("\033[K\n");

	sim(n);

	printf("\033[3E");
}

int main(int argc, char *argv[])
{
	delay.tv_sec = 0;
	delay.tv_nsec = 200000000; // 200 ms
	run(8);
	return 0;
}
