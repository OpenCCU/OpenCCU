// SPDX-License-Identifier: Apache-2.0
#ifndef OPENCCU_LED_PROTOCOL_H
#define OPENCCU_LED_PROTOCOL_H
#include <cerrno>
#include <cstring>
#include <poll.h>
#include <string>
#include <sys/socket.h>
#include <sys/un.h>
#include <unistd.h>

namespace LedProtocol {
static const char socketPath[] = "/run/rpi-rf-mod-led/control";
// One request and one acknowledgement per connection. Bounded waits keep a
// missing or wedged daemon from blocking hss_led's status checks indefinitely.
inline bool request(const std::string& path, const std::string& message,
                    std::string& reply, int timeout = 500) {
  sockaddr_un address = {};
  address.sun_family = AF_UNIX;
  if (path.size() >= sizeof(address.sun_path)) return false;
  std::memcpy(address.sun_path, path.c_str(), path.size() + 1);
  int fd = socket(AF_UNIX, SOCK_SEQPACKET | SOCK_CLOEXEC | SOCK_NONBLOCK, 0);
  if (fd < 0) return false;
  bool ok = false;
  if (connect(fd, reinterpret_cast<sockaddr*>(&address), sizeof(address)) == 0 &&
      send(fd, message.data(), message.size(), MSG_NOSIGNAL) == static_cast<ssize_t>(message.size())) {
    pollfd event = {fd, POLLIN, 0};
    int ready = poll(&event, 1, timeout);
    if (ready > 0 && (event.revents & POLLIN)) {
      char buffer[1024];
      ssize_t n = recv(fd, buffer, sizeof(buffer), MSG_TRUNC);
      if (n > 0 && n < static_cast<ssize_t>(sizeof(buffer))) {
        reply.assign(buffer, static_cast<size_t>(n));
        ok = reply.compare(0, 2, "OK") == 0;
      }
    }
  }
  close(fd);
  return ok;
}
}
#endif
