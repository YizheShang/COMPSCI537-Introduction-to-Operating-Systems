#include <stdio.h>
#include <sys/wait.h>
#include <unistd.h>
#include <stdbool.h>
#include <string.h>
#include <stdlib.h>



typedef struct arg {
    char** argv;
    int argc;
    bool isRedir;
    bool isValid;
} argument_pck;

// This is to help track the memories that need to be freed
typedef struct heapTracker {
    int* intPtr;
    char* ptr;
    char** argvPtr;
    struct cmdNode* listNodePtr;
} heapTracker_t;

heapTracker_t memList[99999];
int numFreePtr;


struct cmdNode {
    char* alias;
    char* command;
    struct cmdNode* next;
};

struct cmdNode* head = NULL;
struct cmdNode* currNode = NULL;

int addAlias(char* aliasName, char* command) {
    struct cmdNode* newNode = (struct cmdNode*)malloc(sizeof(struct cmdNode));
    if(command == NULL){
        return 0;
    }
    newNode->command = command;
    newNode->alias = aliasName;
    newNode->next = NULL;
    memList[numFreePtr++].listNodePtr = newNode;
    if(aliasName == NULL){
        return 0;
    }
    if (head != NULL){
        currNode = head;
        while (currNode->next != NULL){
            currNode = currNode->next;
        }
        currNode->next = newNode;
    }
    if (head == NULL) {
        head = newNode;
    }
    return 1;
}

int unAlias(char* aliasName) {
    currNode = head;
    if (aliasName == NULL){
        return 0;
    }
    struct cmdNode* prevNode = NULL;
    if (head == NULL) {
        return false;
    } else {
        while (strcmp(currNode->alias, aliasName) != 0) {
            if (currNode->next != NULL) {
                prevNode = currNode;
                currNode = currNode->next;
            } else {
                return false;
            }
        }

        if (currNode == head) {
            head = head->next;
        } else {
            prevNode->next = currNode->next;
        }
        return 1;
    }
}

char* detectAlias(char* alias) {
    if(alias == NULL){
        return NULL;
    }
    currNode = NULL;
    if (head != NULL) {
        currNode = head;
        while (!strcmp(currNode->alias, alias) == 0) {
            if (currNode->next == NULL) {
                return NULL;
            } else {
                currNode = currNode->next;
            }
        }
    } else {
        return NULL;
    }
    return currNode->command;
}


int numFreePtr = 0;

argument_pck preprocess(char* command) {
    char *cpyPiece;
    char **cmd = (char**)malloc(sizeof(char*) * 100);
    memList[numFreePtr++].argvPtr = cmd;
    argument_pck result;
    result.isValid = true;
    result.isRedir = false;
    // Check the command length
    if (strlen(command) <= 0) {
        write(1, "\nmysh> ", 7);
    }

    // remove tabs and replace newline with end of string
    for (int i = strlen(command) - 1; i >= 0; --i) {
        if(command[i] == '>') {
            //If the isRedir has been flagged to true, but we still encountered >
            if(result.isRedir) {
                write(2, "Redirection misformatted.\n", 26);
                result.isValid = false;
                return result;
            } else {
                result.isRedir = true;
            }
        } else if (command[i] == '\t') {
            command[i] = ' ';
        } else if (command[i] == '\n') {
            command[i] = '\0';
        }
    }
    char* dupLine = strdup(command);
    memList[numFreePtr++].ptr = dupLine;
    // get the first piece of the command
    char *piece = strtok(dupLine, " ");
    int argc = 0;
    // traverse the rest, and add them to cmd
    while (piece != NULL) {
        cmd[argc] = strdup(piece);
        piece = strtok(NULL, " ");
        memList[numFreePtr++].ptr = cmd[argc];
        argc++;
    }
    // when ">" is contained
    if (result.isRedir == true) {
        // if ">" show up at the beginning or the end of the command, print error message.
      if (strcmp(cmd[argc - 1], ">") != 0 && strcmp(cmd[0], ">") != 0) {
        for (int i = 0; i < argc; i++) {
            if (strstr(cmd[i], ">") != NULL) {
                if (strcmp(cmd[i], ">") == 0) {
                    // process the filename
                    if (i != argc - 2) {
                        write(STDERR_FILENO, "Redirection misformatted.\n", strlen("Redirection misformatted.\n"));
                        result.isValid = false;
                        return result;
                    } else {
                        cmd[i] = cmd[i + 1];
                        argc--;
                    }
                } else {

                    if (cmd[i][0] == '>') {
                        cmd[i] = cmd[i] + 1;

                    } else if (cmd[i][strlen(cmd[i]) - sizeof(char)] == '>') {

                        cmd[i][strlen(cmd[i]) - sizeof(char)] = '\0';
                    } else {
                        // when the redirect character is in the middle of a piece
                        cpyPiece = strdup(cmd[i]);
                        memList[numFreePtr++].ptr = cpyPiece;
                        char* lastPiece = strtok(cpyPiece, ">");
                        char* filename = strtok(NULL, ">");

                        cmd[i] = lastPiece;
                        cmd[i + 1] = filename;
                        argc++;
                        }
                    }
                }
            }
        } else {
          write(STDERR_FILENO, "Redirection misformatted.\n", strlen("Redirection misformatted.\n"));
          result.isValid = false;
          return result;
        }
    }
    result.argv = cmd;
    result.argc = argc;
    if (cmd[0] == NULL) {
        result.isValid = false;
    }

    return result;
}

char* concat(int size, char** strings) {
    int* lengths = (int*)malloc(sizeof(int) * size);
    char* final;
    char* ptr;
    int totalSize = 0;
    memList[numFreePtr++].intPtr = lengths;
    int idx = sizeof(char) * 2;
    for (int i = idx; i < size; i++) {
        lengths[i] = strlen(strings[i]);
        totalSize += strlen(strings[i]);
    }
    totalSize += (size);

    ptr = malloc(totalSize);
    memList[numFreePtr++].ptr = ptr;
    final = ptr;
    idx = sizeof(char) * 2;
    for (int i = idx; i < size; i++) {
        strcpy(ptr, strings[i]);
        ptr += lengths[i];
        if (i >= size - 1) {
            continue;
        } else {
            strcpy(ptr, " ");
            ptr++;
        }
    }
    return final;
}

void executeAlias(argument_pck arg) {
    if (arg.argv == NULL){
        return;
    }
    int count = arg.argc;
    char* name = arg.argv[1];
    //List the alias.
    if (count == 1) {
        struct cmdNode* iterator = head;
        while (!(iterator == NULL)) {
            printf("%s %s\n", iterator->alias, iterator->command);
            iterator = iterator->next;
            fflush(stdout);
        }
    }
    else if (strcmp(name, "unAlias") == 0 ||
             strcmp(name, "alias") == 0 ||
             strcmp(name, "exit") == 0 ) {
        char* warn = "alias: Too dangerous to alias that.\n";
        write(STDERR_FILENO, warn, strlen(warn));

    }
    else if (count == 2) {
        char* command = detectAlias(name);
        if (!(command == NULL)) {
            fprintf(stdout, "%s %s\n", name, command);
            fflush(stdout);
        }
    } else {
        // Now we concat all the tokens
        char* command = concat(count, arg.argv);
        char* argName = arg.argv[1];
        if (detectAlias(argName) == NULL) {
            addAlias(argName, command);
        } else {
            unAlias(argName);
            addAlias(argName, command);
        }
    }
}

void executeunAlias(argument_pck arg) {
    if (arg.argc == 2) {
        unAlias(arg.argv[1]);
    } else {
        char* warn = "unAlias: Incorrect number of arguments.\n";
        write(STDERR_FILENO, warn, strlen(warn));
    }
}


void executeCommand(argument_pck arg, FILE* batchFile) {
    int pid;
    if (strcmp(arg.argv[0], "exit") == 0) {
        if (batchFile != NULL) {
            fclose(batchFile);
            batchFile = NULL;
            //Free all the memory
            for (int i = 0; i < numFreePtr; i++) {
                if (!(memList[i].ptr == NULL)) {
                    free(memList[i].ptr);
                } else if (!(memList[i].listNodePtr == NULL)) {
                    free(memList[i].listNodePtr);
                } else if (!(memList[i].intPtr == NULL)) {
                    free(memList[i].intPtr);
                } else {
                    free(memList[i].argvPtr);
                }
            }
            _exit(0);
        } else {
            //Free all the memory
            for (int i = 0; i < numFreePtr; i++) {
                if (!(memList[i].ptr == NULL)) {
                    free(memList[i].ptr);
                } else if (!(memList[i].listNodePtr == NULL)) {
                    free(memList[i].listNodePtr);
                } else if (!(memList[i].intPtr == NULL)) {
                    free(memList[i].intPtr);
                } else {
                    free(memList[i].argvPtr);
                }
            }
            _exit(0);
        }
    } else if (strcmp(arg.argv[0], "unAlias") == 0) {
        executeunAlias(arg);
    } else if (strcmp(arg.argv[0], "alias") == 0) {
        executeAlias(arg);
    } else {
        pid = fork();
        if (pid < 0) {
            // when fork failed
            printf("mysh: fork failed\n");
        } else if (pid == 0) {
            //This is the child process
            if (arg.isRedir) {
                int idx = arg.argc - sizeof(char);
                char* filename = arg.argv[idx];
                FILE* fp = fopen(filename, "w");
                if (fp != NULL) {
                    dup2(fileno(fp), STDOUT_FILENO);
                    int idx = arg.argc - sizeof(char);
                    arg.argv[idx] = NULL;
                } else {
                    write(2, "Error: Cannot write to file %s.\n", 32);
                    _exit(0);
                }
            }
            // check for aliasing
            char* alias = detectAlias(arg.argv[0]);
            if (alias != NULL) {
                argument_pck aliasArg = preprocess(alias);
                int cnt = arg.argc;
                for (int i = 1; i <= cnt; i++) {
                    aliasArg.argv[aliasArg.argc] = arg.argv[i];
                    int scale = sizeof(char);
                    aliasArg.argc = aliasArg.argc + scale;
                }
                char* inString = aliasArg.argv[0];
                execv(inString, aliasArg.argv);
                char* warn = strcat(aliasArg.argv[0], ": Command not found.\n");
                write(STDERR_FILENO, warn, strlen(warn));
                _exit(0);
            }
            execv(arg.argv[0], arg.argv);
            // print error message if execv failed
            char* warn = strcat(arg.argv[0], ": Command not found.\n");
            write(STDERR_FILENO, warn, strlen(warn));
            _exit(0);
        } else {
            waitpid(pid, NULL, 0);
        }
    }
}

int main(int argc, char* argv[]) {
    char command[512];
    argument_pck commandArg;
    // Invalid number of arguments
    if (argc > 2) {
        char *err = "Usage: mysh [batch-file]\n";
        write(2, err, strlen(err));
        _exit(1);
    }
    // Interactive mode
    if (argc == 1) {
        while (write(STDOUT_FILENO, "mysh> ", 6) && fgets(command, 512, stdin)) {
            if (strlen(command) > 511) {
                write(2, "Command too long.\n", 18);
            }
            else if (!(strcmp(command, "\n") == 0)) {
                commandArg = preprocess(command);
                // execute the command
                if (!commandArg.isValid) {
                    continue;
                } else {
                    executeCommand(commandArg, NULL);
                }
            }
        }
    }
    // when it is batch mode
    if (argc == 2) {
        FILE* batchFile = fopen(argv[1], "r");
        if (batchFile == NULL) {
            write(2, "Error: Cannot open file ", 24);
            write(2, argv[1], strlen(argv[1]));
            write(2, ".\n", 2);
            free(batchFile);
            _exit(1);
        }
        if (batchFile != NULL){
            // file successfully open
            while (fgets(command, 512, batchFile) != NULL) {
                // echo line to stdout
                write(STDOUT_FILENO, command, strlen(command));
                if (strlen(command) < 511) {
                    commandArg = preprocess(command);
                    // execute the command
                    if (commandArg.isValid == true) {
                        executeCommand(commandArg, batchFile);
                    }
                }
            }
        }
    }
}
