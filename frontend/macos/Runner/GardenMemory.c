#include "GardenMemory.h"
#include <sys/mman.h>

int garden_memory_open(const char *name, int flags, mode_t mode) {
  return shm_open(name, flags, mode);
}
