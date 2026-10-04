#include <stdint.h>
#include <sys/stat.h>

typedef int (*garden_entry_callback)(void *, const char *, const struct stat *, int64_t);
void *garden_remote_start(void *engine, const char *mountpoint, const char *name);
int garden_remote_run(void *mount);
void garden_remote_stop(void *mount);
void garden_remote_destroy(void *mount);
int garden_remote_invalidate(void *mount, const char *path);
int garden_remote_attributes(void *engine, const char *path, uint64_t handle, struct stat *attributes);
int garden_remote_open(void *engine, const char *path, int directory, uint64_t *handle);
int garden_remote_close(void *engine, uint64_t handle);
int garden_remote_read(void *engine, uint64_t handle, void *buffer, int64_t offset, int64_t length);
int garden_remote_create(void *engine, const char *path, uint32_t permissions, int folder, uint64_t *handle);
int garden_remote_write(void *engine, uint64_t handle, const void *buffer, int64_t offset, int64_t length, int append);
int garden_remote_truncate(void *engine, const char *path, uint64_t handle, int64_t size);
int garden_remote_flush(void *engine, uint64_t handle);
int garden_remote_list(void *engine, uint64_t handle, int64_t offset, void *context, garden_entry_callback callback);
int garden_remote_mutate(void *engine, int operation, const char *path, const char *destination, int no_replace);
int garden_remote_set_birthtime(void *engine, const char *path, uint64_t handle, int64_t seconds, int64_t nanos);
struct garden_file_attributes {
  uint32_t fields;
  uint32_t permissions;
  uint32_t flags;
  int64_t created_seconds, created_nanos;
  int64_t modified_seconds, modified_nanos;
  int64_t accessed_seconds, accessed_nanos;
};
#define GARDEN_ATTRIBUTE_CREATED 1
#define GARDEN_ATTRIBUTE_MODIFIED 2
#define GARDEN_ATTRIBUTE_ACCESSED 4
#define GARDEN_ATTRIBUTE_PERMISSIONS 8
#define GARDEN_ATTRIBUTE_FLAGS 16
int garden_remote_set_attributes(void *engine, const char *path, uint64_t handle, const struct garden_file_attributes *attributes);
int garden_remote_get_attribute(void *engine, const char *path, const char *name, void *buffer, int64_t length, uint32_t position);
int garden_remote_set_attribute(void *engine, const char *path, const char *name, const void *buffer, int64_t length, int options);
int garden_remote_list_attributes(void *engine, const char *path, void *buffer, int64_t length);
int garden_remote_remove_attribute(void *engine, const char *path, const char *name);
