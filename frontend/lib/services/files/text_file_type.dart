bool isTextFile(String name) {
  final lower = name.toLowerCase();
  if (const {'readme', 'license', 'makefile', 'dockerfile'}.contains(lower)) {
    return true;
  }
  final dot = lower.lastIndexOf('.');
  return dot >= 0 &&
      const {
        'txt',
        'md',
        'csv',
        'json',
        'yaml',
        'yml',
        'xml',
        'html',
        'css',
        'js',
        'ts',
        'tsx',
        'jsx',
        'dart',
        'swift',
        'py',
        'rs',
        'go',
        'c',
        'h',
        'cpp',
        'sh',
        'toml',
        'ini',
        'log',
        'sql',
      }.contains(lower.substring(dot + 1));
}
