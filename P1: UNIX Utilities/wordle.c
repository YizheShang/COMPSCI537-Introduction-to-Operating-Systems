//////////////////////////////////////////////////////
//Course: CS537 Spr. 2022
//Section: Lec 001
//Author: Yizhe Shang
//Project Name: P1: UNIX Utilities wordle.c
/////////////////////////////////////////////////////

#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>


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


int main(int argc, char *argv[]) {
	if (argc != 3) {
                printf("wordle: invalid number of args\n");
                exit(1);
        }

	FILE *fp;
        fp = fopen(argv[1], "r");
        if (fp == NULL) {
        	printf("wordle: cannot open file\n");
                exit(1);
        }

	char *str = argv[2];
	char input[260];
	while (fgets(input, 260, fp) != NULL) {	
		if (strlen(input)-1 != 5) continue;
		char *ptr;
		for (int i = 0; i < strlen(str); i++) {
			ptr = strchr(input, str[i]);
			if (ptr != NULL) break;

		}

		if (ptr == NULL) printf("%s", input);
	}
	
	fclose(fp);

	return 0;
}
