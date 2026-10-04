#define FUSE_USE_VERSION 31
#define FUSE_DARWIN_ENABLE_EXTENSIONS 1
#include <fuse3/fuse.h>
#include <fuse3/fuse_lowlevel.h>
#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <pthread.h>
#include <stdlib.h>
#include "RemoteFuse.h"

static int load_attributes(const char *path, struct stat *out, struct fuse_file_info *file) {
  return garden_remote_attributes(fuse_get_context()->private_data, path, file ? file->fh : 0, out);
}

static int attributes(const char *path, struct fuse_darwin_attr *out, struct fuse_file_info *file) {
  struct stat item;
  int result = load_attributes(path, &item, file);
  if (result != 0) return result;
  memset(out, 0, sizeof(*out));
  out->ino = item.st_ino;
  out->mode = item.st_mode;
  out->nlink = item.st_nlink;
  out->uid = item.st_uid;
  out->gid = item.st_gid;
  out->size = item.st_size;
  out->blocks = item.st_blocks;
  out->blksize = item.st_blksize;
  out->atimespec = item.st_atimespec;
  out->mtimespec = item.st_mtimespec;
  out->ctimespec = item.st_ctimespec;
  out->btimespec = item.st_birthtimespec;
  return 0;
}

static int access_item(const char *path, int mask) {
  struct stat item;
  int result = garden_remote_attributes(fuse_get_context()->private_data, path, 0, &item);
  if (result != 0) return result;
  if ((mask & W_OK) && !S_ISDIR(item.st_mode)) return -EROFS;
  if ((mask & X_OK) && !S_ISDIR(item.st_mode)) return -EACCES;
  return 0;
}

static int open_file(const char *path, struct fuse_file_info *file) {
  // FSKit opens even read-only requests as O_RDWR. Writes remain rejected by write_file.
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

struct directory_context { void *buffer; fuse_darwin_fill_dir_t fill; };

static int entry(void *context, const char *name, uint64_t inode, int folder, int64_t size, int64_t modified, int64_t next) {
  struct directory_context *directory = context;
  struct fuse_darwin_attr attributes = {0};
  attributes.ino = inode;
  attributes.mode = folder ? S_IFDIR | 0755 : S_IFREG | 0444;
  attributes.nlink = 1;
  attributes.uid = getuid();
  attributes.gid = getgid();
  attributes.size = size;
  attributes.mtimespec.tv_sec = modified;
  attributes.ctimespec = attributes.mtimespec;
  attributes.btimespec = attributes.mtimespec;
  return directory->fill(directory->buffer, name, &attributes, next, FUSE_FILL_DIR_PLUS);
}

static int read_directory(const char *path, void *buffer, fuse_darwin_fill_dir_t fill, off_t offset,
  struct fuse_file_info *file, enum fuse_readdir_flags flags) {
  struct directory_context context = {buffer, fill};
  return garden_remote_list(fuse_get_context()->private_data, file->fh, offset, &context, entry);
}

static int write_file(const char *path, const char *bytes, size_t length, off_t offset, struct fuse_file_info *file) { return -EROFS; }
static int mkdir_directory(const char *path, mode_t mode) {
  return garden_remote_mutate(fuse_get_context()->private_data, 0, path, NULL, 0);
}
static int unlink_file(const char *path) {
  return garden_remote_mutate(fuse_get_context()->private_data, 2, path, NULL, 0);
}
static int remove_directory(const char *path) {
  return garden_remote_mutate(fuse_get_context()->private_data, 3, path, NULL, 0);
}
static int rename_item(const char *source, const char *destination, unsigned int flags) {
  if (flags & ~RENAME_NOREPLACE) return -EINVAL;
  return garden_remote_mutate(fuse_get_context()->private_data, 1, source, destination, (flags & RENAME_NOREPLACE) != 0);
}
static int truncate_file(const char *path, off_t size, struct fuse_file_info *file) { return -EROFS; }

static int set_attributes(const char *path, struct fuse_darwin_attr *requested, int fields, struct fuse_file_info *file) {
  struct stat current;
  int result = load_attributes(path, &current, file);
  if (result != 0) return result;
  if (getenv("GARDEN_FUSE_TRACE")) fprintf(stderr, "Garden setattr: fields=%x mode=%o uid=%u gid=%u\n", fields,
    requested->mode, requested->uid, requested->gid);
  unsigned int supported = FUSE_SET_ATTR_MODE | FUSE_SET_ATTR_UID | FUSE_SET_ATTR_GID | FUSE_SET_ATTR_FORCE |
    FUSE_SET_ATTR_FILE | FUSE_SET_ATTR_OPEN | FUSE_SET_ATTR_KILL_SUID | FUSE_SET_ATTR_KILL_SGID | FUSE_SET_ATTR_KILL_PRIV |
    FUSE_SET_ATTR_BTIME | FUSE_SET_ATTR_FLAGS | FUSE_SET_ATTR_SIZE;
  if ((unsigned int)fields & ~supported) return -EROFS;
  if ((fields & FUSE_SET_ATTR_MODE) && (requested->mode & 07777) != (current.st_mode & 07777)) return -EROFS;
  if ((fields & FUSE_SET_ATTR_UID) && requested->uid != current.st_uid) return -EPERM;
  if ((fields & FUSE_SET_ATTR_GID) && requested->gid != current.st_gid) return -EPERM;
  if ((fields & FUSE_SET_ATTR_FLAGS) && requested->flags != 0) return -EROFS;
  if ((fields & FUSE_SET_ATTR_SIZE) && requested->size != current.st_size) return -EROFS;
  if (fields & FUSE_SET_ATTR_BTIME) return garden_remote_set_birthtime(fuse_get_context()->private_data, path,
    requested->btimespec.tv_sec, requested->btimespec.tv_nsec);
  return 0;
}

static void *initialize(struct fuse_conn_info *connection, struct fuse_config *config) {
  // Metadata queries use the local index, so no timed refresh or database fetch is needed.
  config->entry_timeout = 0;
  config->attr_timeout = 0;
  config->negative_timeout = 0;
  config->use_ino = 1;
  // The engine retains deleted content through open handles; no cloud .fuse_hidden rename is needed.
  config->hard_remove = 1;
  config->nullpath_ok = 1;
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
  operations.unlink = unlink_file;
  operations.rmdir = remove_directory;
  operations.rename = rename_item;
  operations.truncate = truncate_file;
  operations.setattr = set_attributes;
  char volume[512];
  if (snprintf(volume, sizeof(volume), "volname=%s", name) >= sizeof(volume)) { errno = EINVAL; return NULL; }
  char *escaped = NULL;
  if (fuse_opt_add_opt_escaped(&escaped, volume) != 0) { errno = ENOMEM; return NULL; }
  char *arguments[] = {"GardenRemote", "-o", "backend=fskit", "-o", escaped, "-d"};
  struct fuse_args args = FUSE_ARGS_INIT(getenv("GARDEN_FUSE_TRACE") ? 6 : 5, arguments);
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
int garden_remote_invalidate(void *handle, const char *path) {
  struct remote_mount *mount = handle;
  pthread_mutex_lock(&mount->lock);
  int result = mount->stopped ? -ENODEV : fuse_invalidate_path(mount->fuse, path);
  pthread_mutex_unlock(&mount->lock);
  return result;
}
