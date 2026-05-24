/// In-process token bucket keyed by client IP. Good enough for a single API
/// container; if we ever scale horizontally, swap for Redis.
class IpRateLimiter {
  IpRateLimiter({required this.maxRequests, required this.window});

  final int maxRequests;
  final Duration window;
  final Map<String, List<DateTime>> _hits = {};

  bool allow(String ip) {
    final now = DateTime.now();
    final cutoff = now.subtract(window);
    final list = _hits.putIfAbsent(ip, () => <DateTime>[])
      ..removeWhere((t) => t.isBefore(cutoff));
    if (list.length >= maxRequests) return false;
    list.add(now);
    if (_hits.length > 5000) _gc(cutoff);
    return true;
  }

  void _gc(DateTime cutoff) {
    _hits.removeWhere((_, list) {
      list.removeWhere((t) => t.isBefore(cutoff));
      return list.isEmpty;
    });
  }
}
