enum FileType { image, video, audio, document, code, archive, other }

FileType fileType(String name) {
  final lower = name.toLowerCase();
  final dot = lower.lastIndexOf('.');
  final extension = dot < 0 ? '' : lower.substring(dot + 1);
  return switch (extension) {
    'jpg' ||
    'jpeg' ||
    'png' ||
    'gif' ||
    'webp' ||
    'heic' ||
    'heif' ||
    'avif' ||
    'tif' ||
    'tiff' ||
    'bmp' ||
    'svg' ||
    'dng' => FileType.image,
    'mov' ||
    'mp4' ||
    'm4v' ||
    'webm' ||
    'mkv' ||
    'avi' ||
    'mpeg' ||
    'mpg' ||
    'mts' ||
    'mxf' => FileType.video,
    'mp3' ||
    'wav' ||
    'aiff' ||
    'aif' ||
    'flac' ||
    'm4a' ||
    'aac' ||
    'ogg' ||
    'opus' ||
    'caf' => FileType.audio,
    'md' ||
    'markdown' ||
    'txt' ||
    'pdf' ||
    'rtf' ||
    'doc' ||
    'docx' ||
    'odt' ||
    'pages' => FileType.document,
    'json' ||
    'yaml' ||
    'yml' ||
    'xml' ||
    'html' ||
    'css' ||
    'js' ||
    'ts' ||
    'tsx' ||
    'jsx' ||
    'dart' ||
    'swift' ||
    'py' ||
    'rs' ||
    'go' ||
    'c' ||
    'h' ||
    'cpp' ||
    'sh' ||
    'toml' ||
    'ini' ||
    'sql' => FileType.code,
    'zip' ||
    'tar' ||
    'gz' ||
    'bz2' ||
    'xz' ||
    '7z' ||
    'rar' => FileType.archive,
    _ => FileType.other,
  };
}
