/* From http://www.scriptol.com/programming/sieve.php */

/* Sieve Of Erathosthenes by Denis Sureau */

#include <stdlib.h>
#include <stdio.h>

#define MAX 1000

int all[MAX];

void eratosthenes(int top)
{
  int idx = 0;
  int prime = 3;
  int x, j;
		
  printf("1 ");
	
  while(prime <= top)
  {
    for(x = 0; x < top; x++)
    {
      if(all[x] == prime) goto skip;
    }

    printf("%d ", prime);
    j = prime;
    while(j <= (top / prime))
    {
      all[idx++] = prime * j;
      j += 1;
    }

skip:	
    prime+=2;
  }
  puts("");
  return;
}

int main()
{
  printf("\n\n\nPrime numbers up to %d:\n", MAX);
  eratosthenes(MAX);
  printf("\nDone.\n");
  return 0;
}
