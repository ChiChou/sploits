#include <dispatch/dispatch.h>
#import <objc/runtime.h>

#include "fishhook/fishhook.h"

#include "log.h"

typedef uint32_t csr_config_t;
static int (*orig_csr_check)(csr_config_t);
static BOOL (*orig_oskext_basic_fs_auth)(id);


/* allow unsigned KEXT and disable staging */
int my_csr_check(csr_config_t mask) {
  LOG(@"calling csr_check %d", mask);
  return 0;
}

/* disable filesystem permission check */
static BOOL my_oskext_basic_fs_auth(id url) {
  LOG(@"calling _OSKextBasicFilesystemAuthentication: %@", url);
  return YES;
}

void hook_csr_check() {
  struct rebinding hooks[] = {
    {"csr_check", my_csr_check, (void *)&orig_csr_check},
    {"_OSKextBasicFilesystemAuthentication", my_oskext_basic_fs_auth, (void *)&orig_oskext_basic_fs_auth},
  };
  rebind_symbols(hooks, sizeof(hooks) / sizeof(struct rebinding));
}

static BOOL can_load(id self, SEL sel, NSURL *url, NSError **error) {
  LOG(@"asked to load extension: %@", url);
  if (error)
    *error = nil;
  return YES;
}

/*

@interface SPKernelExtensionPolicy :
{
}

- (char) canLoadKernelExtension:error:
- (char) canLoadKernelExtensionInCache:error:
@end

*/

void skel_bypass() {
  Class clazz = NSClassFromString(@"SPKernelExtensionPolicy");
  SEL sel = NSSelectorFromString(@"canLoadKernelExtension:error:");
  Method original = class_getInstanceMethod(clazz, sel);
  IMP ret = method_setImplementation(original, (IMP)can_load);
}

void kextload() {
  // at this point, all kextload commands will succeed
  dispatch_async(dispatch_get_main_queue(), ^() {
    NSTask *task = [NSTask launchedTaskWithLaunchPath:@"/sbin/kextload"
                                            arguments:@[ @"/tmp/Unrootless.kext" ]];
  });
}

void load_kext() {
  LOG(@"Patch userland validation");
  hook_csr_check();
  skel_bypass();
  kextload();
}
