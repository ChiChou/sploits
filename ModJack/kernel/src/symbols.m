#include <dlfcn.h>
#include <libproc.h>
#include <string.h>
#include <sys/proc_info.h>

#include "injector.h"

#include "log.h"

pid_t find_kextd() {
  int count = proc_listpids(PROC_ALL_PIDS, 0, NULL, 0);
  pid_t pids[1024];
  memset(pids, 0, sizeof pids);
  proc_listpids(PROC_ALL_PIDS, 0, pids, sizeof pids);

  char path[PROC_PIDPATHINFO_MAXSIZE] = {0};
  for (int i = 0; i < count; i++) {
    pid_t pid = pids[i];
    if (!pid)
      continue;

    proc_pidpath(pids[i], path, sizeof path);
    int len = strlen(path);
    if (!len)
      continue;

    if (strcmp(path, "/usr/libexec/kextd") == 0)
      return pid;
  }

  LOG(@"fatal error: kextd exited unexpectly");
  return 0;
}

void inject_kextd() {
  int status;
  pid_t kextd = find_kextd();
  Dl_info info;
  status = dladdr((void *)inject_kextd, &info);
  if (!status) {
    LOG(@"fatal error: failed to get module info");
    exit(-1);
  }

  void *path = realpath(info.dli_fname, NULL);
  LOG(@"inject %s to kextd", path);
  inject(kextd, path);
  free(path);
}