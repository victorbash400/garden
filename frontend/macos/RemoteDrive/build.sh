#!/bin/bash
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
output="${1:?Pass the output executable path}"
entry="${2:-$root/RemoteDrive/Engine/RemoteMain.swift}"
if [[ $# -ge 2 ]]; then shift 2; else shift; fi
fuse_sdk="${GARDEN_FUSE_SDK:-/usr/local}"
test -f "$fuse_sdk/include/fuse3/fuse.h" || { echo 'Install macFUSE with its userspace SDK first.' >&2; exit 1; }
mkdir -p "$(dirname "$output")"
object="$(mktemp /tmp/garden-fuse.XXXXXX)"
trap 'rm -f "$object"' EXIT
xcrun clang -O2 -I "$fuse_sdk/include" -c "$root/RemoteDrive/Transport/RemoteFuse.c" -o "$object"
xcrun swiftc -O -parse-as-library -swift-version 5 -import-objc-header "$root/RemoteDrive/Transport/RemoteFuse.h" \
  "$root/RemoteDrive/Engine/RemoteCallbacks.swift" "$root/RemoteDrive/Engine/RemoteChanges.swift" \
  "$root/RemoteDrive/Engine/RemoteEngine.swift" "$root/RemoteDrive/Engine/RemoteMetadata.swift" \
  "$root/RemoteDrive/Engine/RemoteMutation.swift" "$root/RemoteDrive/Engine/RemoteMutationJournal.swift" \
  "$root/RemoteDrive/Engine/RemoteWriteDatabase.swift" "$root/RemoteDrive/Engine/RemoteWriteJournal.swift" \
  "$root/RemoteDrive/Engine/RemoteWriteReader.swift" "$root/RemoteDrive/Engine/RemoteWritePublisher.swift" \
  "$root/RemoteDrive/Engine/RemoteEngineAttributes.swift" "$root/RemoteDrive/Engine/RemoteAttributeCallbacks.swift" \
  "$root/RemoteDrive/Engine/RemoteExtendedAttributeCallbacks.swift" \
  "$root/RemoteDrive/Engine/RemoteEngineWrites.swift" "$root/RemoteDrive/Engine/RemoteWriteCallbacks.swift" \
  "$root/RemoteDrive/Engine/RemoteCompletion.swift" "$root/RemoteDrive/Engine/RemoteUnmountCommand.swift" "$root/RemoteDrive/Engine/RemoteMount.swift" "$root/RemoteDrive/Engine/RemotePlatform.swift" "$root/RemoteDrive/Engine/RemoteSubscription.swift" "$entry" \
  "$root/RemoteDrive/Control/RemoteRegistration.swift" "$root/RemoteDrive/Control/RemoteManager.swift" \
  "$root/RemoteDrive/Control/RemoteControlService.swift" "$root/RemoteDrive/Control/RemoteCacheControl.swift" \
  "$root/FinderShared/GardenRemoteControlProtocol.swift" "$root/FinderShared/GardenCacheServiceProtocol.swift" \
  "$root/FinderShared/FinderCredential.swift" "$root/FinderShared/GardenNode.swift" \
  "$root/FinderShared/GardenFileAttributes.swift" \
  "$root/FinderShared/GardenAPI.swift" "$root/FinderShared/GardenMultipartUpload.swift" \
  "$root/FinderShared/GardenBandwidth.swift" "$root/FinderShared/GardenObjectRequests.swift" "$root/FinderShared/GardenRangeCache.swift" \
  "$root/FinderShared/GardenRangeWriter.swift" "$root/FinderShared/GardenReadBuffer.swift" "$root/FinderShared/GardenReadPermits.swift" \
  "$root/FinderShared/GardenDiskCache.swift" "$root/FinderShared/GardenCacheDatabase.swift" \
  "$root/FinderShared/GardenCachePolicy.swift" "$root/FinderShared/GardenCacheWatch.swift" \
  "$@" "$object" -L "$fuse_sdk/lib" -lfuse3 -lsqlite3 -o "$output"
