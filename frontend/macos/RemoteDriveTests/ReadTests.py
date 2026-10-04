"""Compare mounted video ranges and mmap reads with original sample files."""
import mmap
import pathlib
import sys
import time

mounted = pathlib.Path(sys.argv[1])
originals = pathlib.Path(sys.argv[2])
count = 0
for remote in sorted(mounted.iterdir()):
    if not remote.is_file():
        continue
    original = originals / remote.name
    if not original.is_file():
        raise FileNotFoundError(original)
    started = time.monotonic()
    size = original.stat().st_size
    assert remote.stat().st_size == size, remote.name
    with remote.open('rb') as actual, original.open('rb') as expected:
        for offset in (0, size // 2, max(0, size - 65536)):
            actual.seek(offset)
            expected.seek(offset)
            assert actual.read(65536) == expected.read(65536), (remote.name, offset)
        with mmap.mmap(actual.fileno(), 0, access=mmap.ACCESS_READ) as mapped:
            offset = size // 3
            expected.seek(offset)
            assert mapped[offset:offset + 65536] == expected.read(65536), remote.name
    assert remote.stat().st_blocks == 0, remote.name
    count += 1
    print(f'{remote.name}: byte-correct ranges, mmap, 0 allocated blocks, {time.monotonic() - started:.2f}s', flush=True)
assert count > 0, 'No files were tested'
