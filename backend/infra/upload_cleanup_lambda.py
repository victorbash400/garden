import os
import urllib.request


def handler(version_id, _context):
    if not isinstance(version_id, int) or version_id <= 0:
        raise ValueError("Invalid file version ID")

    request = urllib.request.Request(
        os.environ["GARDEN_CLEANUP_URL"],
        data=str(version_id).encode("ascii"),
        headers={"Authorization": "Bearer " + os.environ["GARDEN_CLEANUP_TOKEN"]},
        method="POST",
    )
    with urllib.request.urlopen(request, timeout=20) as response:
        if response.status != 200:
            raise RuntimeError("Upload cleanup failed")
