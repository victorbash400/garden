class TransferCancelled implements Exception {
  const TransferCancelled();
}

class TransferCancellation {
  bool _cancelled = false;
  bool get cancelled => _cancelled;
  void cancel() => _cancelled = true;
  void check() {
    if (_cancelled) throw const TransferCancelled();
  }
}
