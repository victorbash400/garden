"""Compare decoded frames after seeking through a mounted remote video."""
import argparse
import pathlib
import shutil
import subprocess
import time

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('mounted', type=pathlib.Path)
parser.add_argument('original', type=pathlib.Path)
parser.add_argument('--seek', type=float, nargs='+', default=[30, 120])
parser.add_argument('--frames', type=int, default=30)
args = parser.parse_args()
if args.frames <= 0 or any(offset < 0 for offset in args.seek):
    parser.error('Frame count must be positive and seek offsets must be nonnegative')
ffmpeg = shutil.which('ffmpeg')
if ffmpeg is None:
    raise FileNotFoundError('ffmpeg is required')
assert args.mounted.stat().st_size == args.original.stat().st_size

for offset in args.seek:
    outputs = []
    for label, path in [('local', args.original), ('mounted', args.mounted)]:
        started = time.monotonic()
        result = subprocess.run([
            ffmpeg, '-nostdin', '-v', 'error', '-ss', str(offset), '-i', str(path),
            '-map', '0:v:0', '-frames:v', str(args.frames), '-an', '-f', 'framemd5', '-',
        ], capture_output=True, check=True)
        frames = [line for line in result.stdout.splitlines() if line and not line.startswith(b'#')]
        assert len(frames) == args.frames, (label, offset, len(frames))
        outputs.append(result.stdout)
        print(f'{label}: seek {offset:g}s, {args.frames} frames in {time.monotonic() - started:.2f}s', flush=True)
    assert outputs[0] == outputs[1], f'Decoded frames differ at {offset:g}s'
    assert args.mounted.stat().st_blocks == 0, 'Mounted file allocated blocks'
print('Decoded frames match at every seek; mounted file has zero allocated blocks', flush=True)
