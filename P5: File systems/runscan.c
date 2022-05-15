#include <stdio.h>
#include "ext2_fs.h"
#include "read_ext2.h"
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <dirent.h>
#include <string.h>

int main(int argc, char **argv) {
	if (argc != 3) {
		printf("expected usage: ./runscan inputfile outputfile\n");
		exit(0);
	}
	
	int fd;

	fd = open(argv[1], O_RDONLY);    /* open disk image */
	
	struct stat st;
	if (stat(argv[2], &st) == -1) {
		mkdir(argv[2], 0666);
	} else {
		printf("Output directory exists!\n");
		exit(1);
	}

	ext2_read_init(fd);
	//int totalGroupSize = block_size * blocks_per_group;
	

	struct ext2_super_block super;
	struct ext2_group_desc group;
	
	for (uint t = 0; t < num_groups; t++) {
	
		// must read first the super-block and group-descriptor
		read_super_block(fd, t, &super);
		read_group_desc(fd, t, &group);
		
		//printf("There are %u inodes in an inode table block and %u blocks in the idnode table\n", inodes_per_block, itable_blocks);

		//iterate the first inode block
		off_t start_inode_table = locate_inode_table(t, &group);

		for (uint i = 0; i < itable_blocks; i++) {
			struct ext2_inode *inode = malloc(sizeof(struct ext2_inode));
			char buffer[1024]; // Used to store data.
			
			// Iterate blocks.
			for (uint j = 0; j < inodes_per_block; j++) {
				// Get info.
				read_inode(fd, t, start_inode_table, i * inodes_per_block + j, inode);
				// Check if it is a regular file.
				if (S_ISREG(inode->i_mode)) {
					lseek(fd,  BLOCK_OFFSET(inode->i_block[0]), SEEK_SET);
					read(fd, buffer, 1024);
					// Check if it is JPG file.
					int is_jpg = 0;
					if (buffer[0] == (char)0xff &&
						buffer[1] == (char)0xd8 &&
						buffer[2] == (char)0xff &&
						(buffer[3] == (char)0xe0 ||
						buffer[3] == (char)0xe1 ||
						buffer[3] == (char)0xe8)) {
						is_jpg = 1;
					}
					// If it is JPG file.
					if (is_jpg) {
						// Create and open the output file.
						char name[50];
						sprintf(name, "%s/file-%d.jpg", argv[2], i * inodes_per_block + j);
						//printf("Name is %s\n", name);
						mode_t mode = S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH;
						int fd2 = open(name, O_CREAT | O_RDONLY | O_WRONLY, mode);
						uint size = inode->i_size;
						// Iterate blocks to read data.
						uint b;
						for (b = 0; b < 16; b++){
							if (size == 0) break;
							// If in direct inodes.
							if (b < 12) {
								if (size > 0 && size < 1024) {
									lseek(fd, BLOCK_OFFSET(inode->i_block[b]), SEEK_SET);
									read(fd, buffer, size);
									write(fd2, buffer, size); 
									size -= size;
								} else {
									lseek(fd,  BLOCK_OFFSET(inode->i_block[b]), SEEK_SET);
									read(fd, buffer, 1024);
									write(fd2, buffer, 1024); 
									size -= 1024;
								}
							// If in indirect indoes.
							} else if (b == 12) {
								uint buffer2[256];
								lseek(fd,  BLOCK_OFFSET(inode->i_block[b]), SEEK_SET);
								read(fd, buffer2, 1024);
						
								for (uint h = 0; h < 256; h++) {
									//printf("FOR LOOP ENTERED\n");
									if (size == 0) break;
									if (size > 0 && size < 1024) {
										lseek(fd,  BLOCK_OFFSET(buffer2[h]), SEEK_SET);
										read(fd, buffer, size);
										write(fd2, buffer, size); 
										size -= size;
									} else {
										lseek(fd,  BLOCK_OFFSET(buffer2[h]), SEEK_SET);
										read(fd, buffer, 1024);
										write(fd2, buffer, 1024); 
										size -= 1024;
									}		
								}							
							// If in double indirect inode.
							} else if (b == 13) {
								uint doubleIndBuffer[1024];
								uint indBuffer[1024];
								lseek(fd,  BLOCK_OFFSET(inode->i_block[b]), SEEK_SET);
								read(fd, doubleIndBuffer, 1024);

								for (int h1 = 0; h1 < 256 ; h1++) {
									lseek(fd,  BLOCK_OFFSET(doubleIndBuffer[h1]), SEEK_SET);
									read(fd, indBuffer, 1024);
									for (uint h2 = 0; h2 < 256; h2++) {
										if (size == 0) break;
										if (size > 0 && size < 1024) {
											lseek(fd,  BLOCK_OFFSET(indBuffer[h2]), SEEK_SET);
											read(fd, buffer, size);
											write(fd2, buffer, size); 
											size -= size;
										} else {
											//printf("Size is: %d\n", size);
											lseek(fd, BLOCK_OFFSET(indBuffer[h2]), SEEK_SET);
											//printf("lseek() is done\n");
											read(fd, buffer, 1024);
											write(fd2, buffer, 1024); 
											size -= 1024;
										}		
									}	
								}
							}
						}
						close(fd2);					
					}	
				// If the file is not a regular file but a directory;			
				} else {
					//printf("Else enter\n");
					lseek(fd, BLOCK_OFFSET(inode->i_block[0]), SEEK_SET);
					read(fd, buffer, 1024); /*buffer here is the directory buffer*/
					struct ext2_dir_entry_2 *entryPointer = malloc(sizeof(struct ext2_dir_entry_2));
					uint offset = 0;
					// uint b1;
					 while(offset < block_size) {
						char name[EXT2_NAME_LEN];
						memcpy(&entryPointer->inode, buffer + offset, 4);
						memcpy(&entryPointer->rec_len, buffer + offset + 4, 2);
						memcpy(&entryPointer->name_len, buffer + offset + 6, 1);
						memcpy(name, buffer + offset + 8, entryPointer->name_len);

						if (entryPointer->name_len % 4 != 0) {
							offset += 8 + entryPointer->name_len + 4 - (entryPointer->name_len % 4);
						} else {
							offset += 8 + entryPointer->name_len;
						}
						
						//printf("OFFSET IS: %d\n", offset);
						char bufferInode[1024];
						read_inode(fd, t, start_inode_table, entryPointer->inode, inode);
						if (S_ISREG(inode->i_mode)) {
							//printf("It's a regular onr\n");
							lseek(fd, BLOCK_OFFSET(inode->i_block[0]), SEEK_SET);
							read(fd, bufferInode, 1024); 
							int is_jpg = 0;
							if (bufferInode[0] == (char)0xff &&
								bufferInode[1] == (char)0xd8 &&
								bufferInode[2] == (char)0xff &&
								(bufferInode[3] == (char)0xe0 ||
								bufferInode[3] == (char)0xe1 ||
								bufferInode[3] == (char)0xe8)) {
								is_jpg = 1;
							}
							// If it is JPG file.
							if (is_jpg) {
								//printf("It's jpg one\n");
								// Create and open the output file.
								char name2[500];
								sprintf(name2, "./%s/%s", argv[2], name);
								//printf("Name is %s\n", name);
								mode_t mode = S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH;
								int fd2 = open(name2, O_CREAT | O_RDONLY | O_WRONLY, mode);
								uint size = inode->i_size;
								// Iterate blocks to read data.
								uint b2;
								for (b2 = 0; b2 < 16; b2++){
									if (size == 0) break;
									// If in direct inodes.
									if (b2 < 12) {
										if (size > 0 && size < 1024) {
											lseek(fd, BLOCK_OFFSET(inode->i_block[b2]), SEEK_SET);
											read(fd, bufferInode, size);
											write(fd2, bufferInode, size); 
											size -= size;
										} else {
											lseek(fd, BLOCK_OFFSET(inode->i_block[b2]), SEEK_SET);
											read(fd, bufferInode, 1024);
											write(fd2, bufferInode, 1024); 
											size -= 1024;
										}
									// If in indirect indoes.
									} else if (b2 == 12) {
										uint buffer2[256];
										lseek(fd, BLOCK_OFFSET(inode->i_block[b2]), SEEK_SET);
										read(fd, buffer2, 1024);
								
										for (uint h = 0; h < 256; h++) {
											//printf("FOR LOOP ENTERED\n");
											if (size == 0) break;
											if (size > 0 && size < 1024) {
												lseek(fd, BLOCK_OFFSET(buffer2[h]), SEEK_SET);
												read(fd, bufferInode, size);
												write(fd2, bufferInode, size); 
												size -= size;
											} else {
												lseek(fd, BLOCK_OFFSET(buffer2[h]), SEEK_SET);
												read(fd, bufferInode, 1024);
												write(fd2, bufferInode, 1024); 
												size -= 1024;
											}		
										}							
									// If in double indirect inode.
									} else if (b2 == 13) {
										uint doubleIndBuffer[1024];
										uint indBuffer[1024];
										lseek(fd, BLOCK_OFFSET(inode->i_block[b2]), SEEK_SET);
										read(fd, doubleIndBuffer, 1024);

										for (int h1 = 0; h1 < 256 ; h1++) {
											lseek(fd, BLOCK_OFFSET(doubleIndBuffer[h1]), SEEK_SET);
											read(fd, indBuffer, 1024);
											for (uint h2 = 0; h2 < 256; h2++) {
												if (size == 0) break;
												if (size > 0 && size < 1024) {
													lseek(fd, BLOCK_OFFSET(indBuffer[h2]), SEEK_SET);
													read(fd, bufferInode, size);
													write(fd2, bufferInode, size); 
													size -= size;
												} else {
													lseek(fd, BLOCK_OFFSET(indBuffer[h2]), SEEK_SET);
													read(fd, bufferInode, 1024);
													write(fd2, bufferInode, 1024); 
													size -= 1024;
												}	
											}
										}	
										//memset(doubleIndBuffer, 0, 1024);
									}
								}
								close(fd2);	
							}				
						}
						memset(name, 0, EXT2_NAME_LEN);
					}
					free(entryPointer);
				}
			}
			free(inode);
		}
	}
	close(fd);
}
