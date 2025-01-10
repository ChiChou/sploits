#include <dlfcn.h>

#include "injector.h"

void *routine(void *);

void bootstrap(Ctx *ctx) {
  char dummy[128];
  ctx->set_self(dummy);

  pthread_attr_t attr;
  ctx->pthread_attr_init(&attr);

  int policy;
  ctx->pthread_attr_getschedpolicy(&attr, &policy);
  ctx->pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
  ctx->pthread_attr_setinheritsched(&attr, PTHREAD_EXPLICIT_SCHED);

  struct sched_param sched;
  sched.sched_priority = ctx->sched_get_priority_max(policy);
  ctx->pthread_attr_setschedparam(&attr, &sched);

  pthread_t thread;
  ctx->pthread_create(&thread, &attr, ctx->routine, ctx);
  ctx->pthread_attr_destroy(&attr);

  ctx->thread_suspend(ctx->mach_thread_self());
}

void *routine(void *param) {
  Ctx *ctx = param;
  ctx->dlopen(ctx->path, RTLD_NOW);
  return NULL;
}
