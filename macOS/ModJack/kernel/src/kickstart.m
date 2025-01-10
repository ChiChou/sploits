#include <mach/mach.h>
#include <servers/bootstrap.h>

#include "log.h"

kern_return_t kickstart(char *name) {
  kern_return_t kr = KERN_SUCCESS;
  struct nonsense {
    mach_msg_header_t header;
    mach_msg_body_t body;
  };

  mach_port_t bp = MACH_PORT_NULL;
  mach_port_t port = MACH_PORT_NULL;
  kr = task_get_bootstrap_port(mach_task_self(), &bp);

  assert(kr == KERN_SUCCESS);
  kr = bootstrap_look_up(bp, name, &port);

  if (kr != KERN_SUCCESS) {
    LOG(@"Unable to lookup %s", name);
    return kr;
  }

  struct nonsense msg = {0};
  msg.header.msgh_bits = MACH_MSGH_BITS_COMPLEX | MACH_MSGH_BITS(MACH_MSG_TYPE_COPY_SEND, 0);
  msg.header.msgh_remote_port = port;
  msg.header.msgh_local_port = MACH_PORT_NULL;
  msg.header.msgh_id = 0xdeadbeef;

  mach_msg(&msg.header, MACH_SEND_MSG | MACH_MSG_OPTION_NONE, (mach_msg_size_t)sizeof(struct nonsense), 0,
           MACH_PORT_NULL, MACH_MSG_TIMEOUT_NONE, MACH_PORT_NULL);

  return KERN_SUCCESS;
}