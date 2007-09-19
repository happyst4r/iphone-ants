
#include <IOKit/IOKitLib.h>
#include <CoreFoundation/CoreFoundation.h>

typedef struct {} *IOHIDEventSystemRef;
typedef struct {} *IOHIDEventRef;
float IOHIDEventGetFloatValue(IOHIDEventRef ref, int param);

void handleHIDEvent(int a, int b, int c, IOHIDEventRef ptr) {
  int type = IOHIDEventGetType(ptr);

  if (type == 12) {
    float x,y,z;

    x = IOHIDEventGetFloatValue(ptr, 0xc0000);
    y = IOHIDEventGetFloatValue(ptr, 0xc0001);
    z = IOHIDEventGetFloatValue(ptr, 0xc0002);

    // update the world's accel view

    printf("values: %d, %d, %d, %f, %f, %f\n", a, b, c, x, y, z);
  }
}


#define expect(x) if(!x) { printf("failed: %s\n", #x);  return; }

void initialize(int hz) {
  //mach_port_t master;
  //expect(0 == IOMasterPort(MACH_PORT_NULL, &master));
  int page = 0xff00, usage = 3;

  CFNumberRef nums[2];
  CFStringRef keys[2];
  keys[0] = CFStringCreateWithCString(0, "PrimaryUsagePage", 0);
  keys[1] = CFStringCreateWithCString(0, "PrimaryUsage", 0);
  nums[0] = CFNumberCreate(0, kCFNumberSInt32Type, &page);
  nums[1] = CFNumberCreate(0, kCFNumberSInt32Type, &usage);
  CFDictionaryRef dict = CFDictionaryCreate(0, (const void**)keys, (const void**)nums, 2, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
  expect(dict);

  IOHIDEventSystemRef sys = (IOHIDEventSystemRef) IOHIDEventSystemCreate(0);
  expect(sys);

  CFArrayRef srvs = (CFArrayRef)IOHIDEventSystemCopyMatchingServices(sys, dict, 0, 0, 0);
  expect(CFArrayGetCount(srvs)==1);

  io_registry_entry_t serv = (io_registry_entry_t)CFArrayGetValueAtIndex(srvs, 0);
  expect(serv);

  CFStringRef cs = CFStringCreateWithCString(0, "ReportInterval", 0);
  int rv = 1000000/hz;
  CFNumberRef cn = CFNumberCreate(0, kCFNumberSInt32Type, &rv);

  int res = IOHIDServiceSetProperty(serv, cs, cn);
  expect(res == 1);

  res = IOHIDEventSystemOpen(sys, handleHIDEvent, 1, 1);
  expect(res != 0);
}

int main(int argc, char *argv[])
{
    initialize(1);
    sleep(10);
}
