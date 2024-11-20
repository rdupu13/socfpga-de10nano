#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <unistd.h>

const unsigned int MAX_EQ = 10;
const unsigned int MAX_STR = 10;






/**
 * main() - 
 * 
 */
int main(int argc, char **argv)
{
	int help = 0;
	int verbose = 0;	
	int equation = 0;
	int file = 0;
	
	int opt_argc = 0 ;
	char *opt_args[MAX_EQ];
	
	for (int i = 1; i < argc; i++)
	{
		if (strcmp(opt_args[i], "-h") == 0)
		{
			help = i;
		}
		else if (strcmp(opt_args[i], "-v") == 0)
		{
			verbose = i;
		}
		else if (strcmp(opt_args[i], "-e") == 0)
		{
			equation = i;
		}
		else if (strcmp(opt_args[i], "-f" ) == 0)
		{
			file = i;
		}
		else
		{
			*opt_args[i] = (char *) malloc(MAX_STR * sizeof(char));
			opt_args[i] = argv[i];
			opt_argc++;
		}
	}
	
	printf("h: %d\n", help);
	printf("v: %d\n", verbose);
	printf("e: %d\n", equation);
	printf("f: %d\n", file);
	
	for (int i = 0; i < opt_argc; i++)
	{
		free((void *) *opt_args[i]);
	}
	
	return 0;
}
