#include <stdlib.h>
#include <sys/proc_info.h>
#include <unistd.h>

#include "log.h"
#include "patch.h"

typedef struct {
  const char *key;
  void (*callback)();
} dispatch_entry;

__attribute__((constructor)) void run() {
  dispatch_entry table[] = {
      {"symbols", inject_kextd},
      {"kextd", load_kext},
  };

  const char *name = getprogname();
  LOG(@"I am in %s", name);

  for (size_t i = 0; i < sizeof(table) / sizeof(dispatch_entry); i++) {
    dispatch_entry entry = table[i];
    if (strcmp(entry.key, name) == 0)
      entry.callback();
  }
}