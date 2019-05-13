#include <errno.h>
#include <stdlib.h>
#include <sys/stat.h>

#include "injector.h"

int main(int argc, char *argv[]) {
  if (argc < 3) {
    fprintf(stderr, "Usage: %s _pid_ _action_\n", argv[0]);
    fprintf(stderr, "   _action_: path to a dylib on disk\n");
    exit(0);
  }

  pid_t pid = atoi(argv[1]);
  if (strlen(argv[2]) > PATH_MAX) {
    fprintf(stderr, "Fatal error, path is too long: %s", argv[1]);
    exit(1);
  }
  char lib[PATH_MAX];
  realpath(argv[2], lib);

  struct stat st;
  if (stat(lib, &st) != 0) {
    fprintf(stderr, "Dylib not found %s (%s)\n", lib, strerror(errno));
    exit(1);
  }

  inject(pid, lib);
  return 0;
}