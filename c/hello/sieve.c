/* From http://www.scriptol.com/programming/sieve.php */

/* Sieve Of Erathosthenes by Denis Sureau */

#include <stdlib.h> 
#include <stdio.h>

int all[1000];

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
  printf("\n\n\nPRIME NUMBERS UP TO 1000:\n");
  eratosthenes(1000);
  printf("\nDONE.\n");
  return 0;
}
