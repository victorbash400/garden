#define FUSE_USE_VERSION 31
#define FUSE_DARWIN_ENABLE_EXTENSIONS 0
#include <fuse3/fuse.h>
#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <pthread.h>
#include <stdlib.h>
#include "RemoteFuse.h"

static int attributes(const char *path, struct stat *out, struct fuse_file_info *file) {
  return garden_remote_attributes(fuse_get_context()->private_data, path, file ? file->fh : 0, out);
}

static int access_item(const char *path, int mask) {
  struct stat item;
  int result = garden_remote_attributes(fuse_get_context()->private_data, path, 0, &item);
  if (result != 0) return result;
  if (mask & W_OK) return -EROFS;
  if ((mask & X_OK) && !S_ISDIR(item.st_mode)) return -EACCES;
  return 0;
}

static int open_file(const char *path, struct fuse_file_info *file) {
  if (file->flags & (O_CREAT | O_TRUNC | O_APPEND)) return -EROFS;
  file->keep_cache = 0;
  return garden_remote_open(fuse_get_context()->private_data, path, 0, &file->fh);
}

static int open_directory(const char *path, struct fuse_file_info *file) {
  return garden_remote_open(fuse_get_context()->private_data, path, 1, &file->fh);
}

static int release(const char *path, struct fuse_file_info *file) {
  return garden_remote_close(fuse_get_context()->private_data, file->fh);
}

static int read_file(const char *path, char *buffer, size_t size, off_t offset, struct fuse_file_info *file) {
  return garden_remote_read(fuse_get_context()->private_data, file->fh, buffer, offset, (int64_t)size);
}

struct directory_context { void *buffer; fuse_fill_dir_t fill; };

static int entry(void *context, const char *name, uint64_t inode, int folder, int64_t size, int64_t modified, int64_t next) {
  struct directory_context *directory = context;
  struct stat attributes = {0};
  attributes.st_ino = inode;
  attributes.st_mode = folder ? S_IFDIR | 0555 : S_IFREG | 0444;
  attributes.st_size = size;
  attributes.st_mtime = modified;
  return directory->fill(directory->buffer, name, &attributes, next, FUSE_FILL_DIR_PLUS);
}

static int read_directory(const char *path, void *buffer, fuse_fill_dir_t fill, off_t offset,
  struct fuse_file_info *file, enum fuse_readdir_flags flags) {
  struct directory_context context = {buffer, fill};
  return garden_remote_list(fuse_get_context()->private_data, file->fh, offset, &context, entry);
}

static int write_file(const char *path, const char *bytes, size_t length, off_t offset, struct fuse_file_info *file) { return -EROFS; }
static int mkdir_directory(const char *path, mode_t mode) { return -EROFS; }
static int remove_item(const char *path) { return -EROFS; }
static int rename_item(const char *source, const char *destination, unsigned int flags) { return -EROFS; }
static int truncate_file(const char *path, off_t size, struct fuse_file_info *file) { return -EROFS; }

static void *initialize(struct fuse_conn_info *connection, struct fuse_config *config) {
  // Metadata queries use the local index, so no timed refresh or database fetch is needed.
  config->entry_timeout = 0;
  config->attr_timeout = 0;
  config->negative_timeout = 0;
  config->use_ino = 1;
  return fuse_get_context()->private_data;
}

struct remote_mount { struct fuse *fuse; pthread_mutex_t lock; int stopped; };

void *garden_remote_start(void *engine, const char *mountpoint, const char *name) {
  struct fuse_operations operations = {0};
  operations.init = initialize;
  operations.getattr = attributes;
  operations.access = access_item;
  operations.open = open_file;
  operations.release = release;
  operations.read = read_file;
  operations.opendir = open_directory;
  operations.readdir = read_directory;
  operations.releasedir = release;
  operations.write = write_file;
  operations.mkdir = mkdir_directory;
  operations.unlink = remove_item;
  operations.rmdir = remove_item;
  operations.rename = rename_item;
  operations.truncate = truncate_file;
  char volume[512];
  if (snprintf(volume, sizeof(volume), "volname=%s", name) >= sizeof(volume)) { errno = EINVAL; return NULL; }
  char *escaped = NULL;
  if (fuse_opt_add_opt_escaped(&escaped, volume) != 0) { errno = ENOMEM; return NULL; }
  char *arguments[] = {"GardenRemote", "-o", "backend=fskit", "-o", escaped};
  struct fuse_args args = FUSE_ARGS_INIT(5, arguments);
  struct fuse *mount = fuse_new(&args, &operations, sizeof(operations), engine);
  fuse_opt_free_args(&args);
  free(escaped);
  if (!mount) return NULL;
  if (fuse_mount(mount, mountpoint) != 0) { fuse_destroy(mount); errno = EIO; return NULL; }
  struct remote_mount *result = calloc(1, sizeof(*result));
  if (!result) { fuse_unmount(mount); fuse_destroy(mount); errno = ENOMEM; return NULL; }
  result->fuse = mount;
  pthread_mutex_init(&result->lock, NULL);
  return result;
}


int garden_remote_run(void *handle) {
  struct remote_mount *mount = handle;
  return fuse_loop_mt(mount->fuse, 0);
}
void garden_remote_stop(void *handle) {
  struct remote_mount *mount = handle;
  pthread_mutex_lock(&mount->lock);
  if (!mount->stopped) {
    mount->stopped = 1;
    fuse_exit(mount->fuse);
  }
  pthread_mutex_unlock(&mount->lock);
}
void garden_remote_destroy(void *handle) {
  struct remote_mount *mount = handle;
  garden_remote_stop(handle);
  fuse_destroy(mount->fuse);
  pthread_mutex_destroy(&mount->lock);
  free(mount);
}
