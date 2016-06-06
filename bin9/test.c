#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "crric.h"


int main(void)
{
 int i=0;
 unsigned int res=0;
 char bufin[512];

 while( 1 )
 {
   if( gets((char *)bufin)==NULL ) break;
   if( (i=CheckSIC(bufin, (unsigned int *)&res))!=0 ) {puts((char *)"CheckSIC error."); break;}
   res+=48;
   puts((char *)&res);
 }
}

