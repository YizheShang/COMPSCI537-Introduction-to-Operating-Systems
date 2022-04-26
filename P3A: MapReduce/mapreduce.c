#include "mapreduce.h"

#include <errno.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

struct Node {
  char* key;
  char* value;
};

struct Node** partitions;  // Array storing the nodes
pthread_mutex_t lock, fileLock;
Partitioner partitioner;
Reducer reducer;
Mapper mapper;
int numPartitions;
int totalFiles;                // total num of files
int filesDone;                 // Num of files done
int* allocatedPartitions;      // How many nodes are allocaed in index
int* nodesInPartitions;        // How many nodes are stored in index
int* numOfAccessInPartitions;  // How many accesses are done in index
char** fileNamesPointer;       // 2d array that stores names of all files

char* getValue(char* key, int partitionNum) {
  int num = numOfAccessInPartitions[partitionNum];
  if (num < nodesInPartitions[partitionNum] &&
      strcmp(key, partitions[partitionNum][num].key) == 0) {
      char* value = partitions[partitionNum][num].value;
    // printf("value %s\n", partitions[partitionNum][num].key);
    numOfAccessInPartitions[partitionNum]++;
    return value;
  } else {
    return NULL;
  }
}

int cmp(const void* a, const void* b) {
  struct Node* p1 = (struct Node*)a;
  struct Node* p2 = (struct Node*)b;
  return strcmp(p1->key, p2->key);
}

void* mapperHelper(void* arg) {
  while (1) {
    pthread_mutex_lock(&fileLock);
    if (filesDone >= totalFiles) {
      pthread_mutex_unlock(&fileLock);
      break;
    }
    char* fileName = NULL;
    if (filesDone < totalFiles) {
      fileName = fileNamesPointer[filesDone];
      filesDone++;
    }
    pthread_mutex_unlock(&fileLock);
    if (fileName != NULL) mapper(fileName);
  }
  return arg;
}

void* reducerHelper(void* num) {
  int part = *(int*)num;
  qsort(partitions[part], nodesInPartitions[part], sizeof(struct Node), cmp);
  numOfAccessInPartitions[part] = 0;
  while (numOfAccessInPartitions[part] < nodesInPartitions[part]) {
    reducer(partitions[part][numOfAccessInPartitions[part]].key, getValue,
            part);
  }
  return num;
}

void MR_Emit(char* key, char* value) {
  pthread_mutex_lock(&lock);

  unsigned long partitionNum = partitioner(key, numPartitions);
  nodesInPartitions[partitionNum]++;
  int curCount = nodesInPartitions[partitionNum];
  partitions[partitionNum] = realloc(partitions[partitionNum], nodesInPartitions[partitionNum] * sizeof(struct Node));
  partitions[partitionNum][curCount - 1].key = strdup(key);
  partitions[partitionNum][curCount - 1].value = strdup(value);
  //if (strcmp("1", key) == 0) printf("here%d, %ld\n", curCount, partitionNum);

  pthread_mutex_unlock(&lock);
}

unsigned long MR_DefaultHashPartition(char* key, int num_partitions) {
  unsigned long hash = 5381;
  int c;
  while ((c = *key++) != '\0') hash = hash * 33 + c;
  return hash % num_partitions;
}

void MR_Run(int argc, char* argv[], Mapper map, int num_mappers, Reducer reduce,
            int num_reducers, Partitioner partition) {
  if (argc - 1 < num_mappers) {
    num_mappers = argc - 1;
  }

  // Initialize all global variables.
  pthread_t mapperThreads[num_mappers];
  pthread_t reducerThreads[num_reducers];
  pthread_mutex_init(&lock, NULL);
  pthread_mutex_init(&fileLock, NULL);
  partitioner = partition;
  mapper = map;
  reducer = reduce;
  numPartitions = num_reducers;
  partitions = malloc(num_reducers * sizeof(struct Node*));
  totalFiles = argc - 1;
  filesDone = 0;
  // allocatedPartitions = malloc(num_reducers * sizeof(int));
  nodesInPartitions = malloc(num_reducers * sizeof(int));
  numOfAccessInPartitions = malloc(num_reducers * sizeof(int));
  fileNamesPointer = malloc((argc - 1) * sizeof(char*));
  int arrayPosition[num_reducers];

  // printf("Initialization done\n");
  for (int i = 0; i < num_reducers; i++) {
    partitions[i] = malloc(512 * sizeof(struct Node));
    nodesInPartitions[i] = 0;
    arrayPosition[i] = i;
  }
  // printf("partitions ... done\n");
  for (int i = 0; i < argc - 1; i++) {
    fileNamesPointer[i] = malloc((strlen(argv[i + 1]) + 1) * sizeof(char));
    strcpy(fileNamesPointer[i], argv[i + 1]);
    // printf("%s\n", fileNamesPointer[i]);
  }

  // Create threads
  for (int i = 0; i < num_mappers; i++) {
    pthread_create(&mapperThreads[i], NULL, mapperHelper, NULL);
  }

  // printf("pthread_create is done\n");

  for (int i = 0; i < num_mappers; i++) {
    pthread_join(mapperThreads[i], NULL);
  }
  // printf("pthread_join is done\n");

  for (int i = 0; i < num_reducers; i++) {
    pthread_create(&reducerThreads[i], NULL, reducerHelper,
                       &arrayPosition[i]);
  }

  // printf("pthread_create loop is done\n");

  // Waiting for the threads to finish
  for (int i = 0; i < num_reducers; i++) {
    pthread_join(reducerThreads[i], NULL);
  }

  // Free locks.
  pthread_mutex_destroy(&lock);
  pthread_mutex_destroy(&fileLock);

  for (int i = 0; i < num_reducers; i++) {
    // Freeing the keys and values
    for (int j = 0; j < nodesInPartitions[i]; j++) {
      if (partitions[i][j].key != NULL && partitions[i][j].value != NULL) {
        free(partitions[i][j].key);
        free(partitions[i][j].value);
      }
    }
    // Freeing the pair struct array
    free(partitions[i]);
  }
  free(partitions);

  for (int i = 0; i < argc - 1; i++) {
    free(fileNamesPointer[i]);
  }
  free(fileNamesPointer);
  free(nodesInPartitions);
  free(allocatedPartitions);
  free(numOfAccessInPartitions);
}
