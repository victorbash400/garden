#include <stdint.h>
#include <sys/stat.h>

typedef int (*garden_entry_callback)(void *, const char *, uint64_t, int, int64_t, int64_t, int64_t);
void *garden_remote_start(void *engine, const char *mountpoint, const char *name);
int garden_remote_run(void *mount);
void garden_remote_stop(void *mount);
void garden_remote_destroy(void *mount);
int garden_remote_invalidate(void *mount, const char *path);
int garden_remote_attributes(void *engine, const char *path, uint64_t handle, struct stat *attributes);
int garden_remote_open(void *engine, const char *path, int directory, uint64_t *handle);
int garden_remote_close(void *engine, uint64_t handle);
int garden_remote_read(void *engine, uint64_t handle, void *buffer, int64_t offset, int64_t length);
int garden_remote_list(void *engine, uint64_t handle, int64_t offset, void *context, garden_entry_callback callback);
int garden_remote_mutate(void *engine, int operation, const char *path, const char *destination, int no_replace);
int garden_remote_set_birthtime(void *engine, const char *path, int64_t seconds, int64_t nanos);
