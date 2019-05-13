#include <dlfcn.h>
#include <mach/mach_vm.h>
#include <pthread.h>

#include "gen/offsets.h"
#include "gen/sc.h"

#include "injector.h"

#define CHECK_MACH(kr, op)                                                                                             \
  if (!(kr == KERN_SUCCESS)) {                                                                                         \
    failed_operation = op;                                                                                             \
    goto mach_failure;                                                                                                 \
  } else {                                                                                                             \
    fprintf(stderr, "%s (OK)\n", op);                                                                                  \
  }

int inject(pid_t pid, const char *lib) {
  const char *failed_operation;
  task_t task;
  mach_error_t kr = KERN_SUCCESS;
  kr = task_for_pid(mach_task_self(), pid, &task);
  CHECK_MACH(kr, "get task port");

  mach_vm_address_t stack = 0;
  mach_vm_address_t code = 0;

  kr = mach_vm_allocate(task, &stack, STACK_SIZE, VM_FLAGS_ANYWHERE);
  CHECK_MACH(kr, "allocate stack");
  fprintf(stderr, "remote stack 0x%llx\n", stack);
  kr = mach_vm_allocate(task, &code, CODE_SIZE, VM_FLAGS_ANYWHERE);
  CHECK_MACH(kr, "allocate code");
  fprintf(stderr, "remote code 0x%llx\n", code);
  kr = mach_vm_write(task, code, (vm_address_t)sc, sc_len);
  CHECK_MACH(kr, "write loader code");
  kr = vm_protect(task, code, sc_len, FALSE, VM_PROT_READ | VM_PROT_EXECUTE);
  CHECK_MACH(kr, "mark code as eXecutable");
  kr = vm_protect(task, stack, STACK_SIZE, TRUE, VM_PROT_READ | VM_PROT_WRITE);
  CHECK_MACH(kr, "mark stack as RW");

  Ctx ctx;
  ctx.set_self = dlsym(RTLD_DEFAULT, "_pthread_set_self");

  // Currently they share same framework base addresses
#define CTX_API(NAME) ctx.NAME = NAME
  CTX_API(pthread_attr_init);
  CTX_API(pthread_attr_getschedpolicy);
  CTX_API(pthread_attr_setdetachstate);
  CTX_API(pthread_attr_setinheritsched);
  CTX_API(pthread_attr_setschedparam);
  CTX_API(pthread_create);
  CTX_API(pthread_attr_destroy);
  CTX_API(sched_get_priority_max);
  CTX_API(thread_suspend);
  CTX_API(mach_thread_self);
  CTX_API(dlopen);

  ctx.routine = (void *)code + CODE_ROUTINE_OFFSET;
  strncpy(ctx.path, lib, sizeof(ctx.path));

  kr = mach_vm_write(task, stack, (vm_address_t)&ctx, sizeof(ctx));
  CHECK_MACH(kr, "write params");

  x86_thread_state64_t state;
  memset(&state, 0, sizeof(state));
  state.__rdi = (uint64_t)stack;

  stack += (STACK_SIZE / 2);
  stack = stack & ~0xf; // alignment of 16

  // entry
  state.__rip = (u_int64_t)(vm_address_t)code + CODE_ENTRY_OFFSET;

  // remote stack
  state.__rsp = (u_int64_t)stack;
  state.__rbp = (u_int64_t)stack;

  thread_act_t thread;
  kr = thread_create_running(task, x86_THREAD_STATE64, (thread_state_t)&state, x86_THREAD_STATE64_COUNT, &thread);
  CHECK_MACH(kr, "create remote thread");

  return 0;

mach_failure:
  fprintf(stderr, "Unexpected error: %s returned '%s'", failed_operation, mach_error_string(kr));
  return -1;
}
