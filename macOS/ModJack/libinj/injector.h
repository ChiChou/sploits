#include <mach/mach.h>
#include <pthread.h>
#include <stdio.h>
#include <sys/syslimits.h>
#include <sys/types.h>

typedef struct {
  void *(*set_self)(char *thread);

  int (*pthread_attr_init)(pthread_attr_t *attr);
  int (*pthread_attr_getschedpolicy)(const pthread_attr_t *restrict attr, int *restrict policy);
  int (*pthread_attr_setdetachstate)(pthread_attr_t *attr, int detachstate);
  int (*pthread_attr_setinheritsched)(pthread_attr_t *attr, int inheritsched);
  int (*pthread_attr_setschedparam)(pthread_attr_t *restrict attr, const struct sched_param *restrict param);
  int (*pthread_create)(pthread_t *thread, const pthread_attr_t *attr, void *(*start_routine)(void *), void *arg);
  int (*pthread_attr_destroy)(pthread_attr_t *attr);

  int (*sched_get_priority_max)(int policy);

  kern_return_t (*thread_suspend)(thread_act_t target_act);
  thread_port_t (*mach_thread_self)(void);

  void *(*dlopen)(const char *path, int mode);

  void *routine;
  char path[PATH_MAX];
} Ctx;

#define STACK_SIZE (1024 * 1024 * 32)
#define CODE_SIZE 1024

int inject(pid_t, const char *);