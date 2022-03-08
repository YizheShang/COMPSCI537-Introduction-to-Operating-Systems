//////////////////////////////////////////////////////
//Course: CS537 Spr. 2022
//Section: Lec 001
//Author: Yizhe Shang
//Project Name: P1: UNIX Utilities my-look.c
/////////////////////////////////////////////////////

#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

void printHelpInfo() {
	printf("Help Information of MY-LOOK(Designed by Yizhe Shang)\n");
	printf("NAME: \n    my-look - display lines beginning with a given string.\n");
	printf("\nDESCRIPTION: \n    This is a variant of the original look utility. my-look take a string as input and return any lines in a file that contain that string as a prefix. But my-look have different command line options.\n");
	printf("\n    Same as look, if file is not specified, the file /usr/share/dict/words is used, only alphanumeric characters are compared and the case of alphabetic characters is ignored.\n");
	printf("    The following options are available:\n\n");
	printf("    -V: prints information about this utility; the message should be exactly \"my-look from CS537 Spring 2022\" followed by a newline.  The utility should then exit with status code 0 without processing any more options.  (Note this an upper-case V, not lower-case.  Lower-case v is often used to signify verbose output.)\n");
	printf("    -h: prints help information about this utility; The utility should then exit with status code 0 without processing any more options.\n");
	printf("    -f <filename>: uses <filename> as the input dictionary.  For example, \"my-look -f ./mywords\" will read the file \"./mywords\" for input.  If this option is not specified, then  my-look will read from standard input (i.e., stdin); it will not open a file called stdin!!!\n\n");
	printf("    If my-look encounters any other arguments or has any error parsing the command line arguments, it will exit with status code 1 and print the exact error message \"my-look: invalid command line\"\n");
}

void filter(char *input, char *res) {
	int j = 0;
	for (int i = 0; i < strlen(input); i++) {
		if (isalpha(input[i]) != 0 || isdigit(input[i]) != 0) {
			res[j] = input[i];
			j++;
		}

	}
		
	res[j] = '\0';
	
}

void compare(FILE *fp, char *prefix, int flag) {	
	char input[260];
	char filteredPrefix[260];
	char filteredWords[260];
	int result = 0;
	int prefixLen = 0;



	filter(prefix, filteredPrefix);
	prefixLen = strlen(filteredPrefix);

	if (flag == 1) {
		while (fgets(input, 260, fp) != NULL) {
			filter(input, filteredWords);
			result = strncasecmp(filteredPrefix, filteredWords, prefixLen);
			if (result == 0) printf("%s", input);

		}
	} else {
		while (fgets(input, 100, stdin)) {
			filter(input, filteredWords);

			result = strncasecmp(filteredPrefix, filteredWords, prefixLen);
			if (result == 0) printf("%s", input);
		}	
	}
}


int main(int argc, char* argv[]) {
	int fFlag = 0, opt = 0;
	char *filePath;
	char *prefix;
	FILE *fp;


	if (argc < 2) {
		printf("my-look: invalid command line\n");
                exit(1);
	}
      
	// Get the option in the argument; if my-look is passed both -V and -h, 
	// it will only process the option that it sees first (and then exit).
        while ((opt = getopt(argc, argv, "Vhf:")) != -1) {
       		switch (opt) {
                // Case V: Prints information about this utility.
		case 'V':
		   printf("my-look from CS537 Spring 2022\n");
                   exit(0);
                   break;
		// Case h: Prints help information about this utility.
               	case 'h':
		   printHelpInfo();
                   exit(0);
		   break;
		// Case f: Uses <filename> as the input dictionary; If this 
		// option is not specified, then  my-look will read from 
		// standard input. 
		case 'f':
		   fFlag = 1;
		   filePath = optarg;
		   fp = fopen(filePath, "r");
                   if (fp == NULL) {
                        printf("my-look: cannot open file\n");
                        exit(1);
                   }
		   break;
		case '?':
                   printf("my-look: invalid command line\n");
                   exit(1);
               }
   	}
	prefix = argv[optind];
	compare(fp, prefix, fFlag);
	
	if (fFlag) fclose(fp);




	return 0;
}



