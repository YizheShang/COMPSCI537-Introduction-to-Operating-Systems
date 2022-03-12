#include "types.h"
#include "x86.h"
#include "defs.h"
#include "date.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "pstat.h"

extern uint rseed;

int
sys_fork(void)
{
  return fork();
}

int
sys_exit(void)
{
  exit();
  return 0;  // not reached
}

int
sys_wait(void)
{
  return wait();
}

int
sys_kill(void)
{
  int pid;

  if(argint(0, &pid) < 0)
    return -1;
  return kill(pid);
}

int
sys_getpid(void)
{
  return myproc()->pid;
}

int
sys_sbrk(void)
{
  int addr;
  int n;

  if(argint(0, &n) < 0)
    return -1;
  addr = myproc()->sz;
  if(growproc(n) < 0)
    return -1;
  return addr;
}

int
sys_sleep(void)
{
  int n;   // the amount of time needs to sleep

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  myproc()->sleepTicks = n;
    
  sleep(&ticks, &tickslock);
  
  release(&tickslock);
  return 0;
}

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

// New added syscall defined by Yizhe.
// Set the number of tickets alloted to a process.
// Returns 0 if the pid value is valid and n_tickets is positive.
// Else, it returns -1.
int
sys_settickets(void) {
  int pid;
  int n_tickets;

  // Check if pid is valid and if n_tickets is positive.
  if(argint(0, &pid) < 0 || argint(1, &n_tickets) < 0) return -1;
  if (pid < 0 || n_tickets <= 0) return -1;

  return settickets(pid, n_tickets);
}

// New added syscall defined by Yizhe.
// Set the rseed variable you defined in proc.c.
void
sys_srand(void) {
  uint seed;

  argint(0, (int*)&seed);
  rseed = seed;
}

// New added syscall defined by Yizhe.
// Some basic information about each running process will be returned.
// Returns 0 on success and -1 on failure.
// i goes from 0 -> NPROC; getpinfo returns information about all slots of ptable.
int
sys_getpinfo(void) {
  struct pstat *pStat;

  if (argptr(0, (void*)&pStat, sizeof(*pStat)) < 0) return -1;

  return getpinfo(pStat);
}

