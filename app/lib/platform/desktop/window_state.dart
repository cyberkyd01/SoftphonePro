import 'dart:ui';

/// Remembered window geometry, stored in settings under `windowBounds`.
class SavedWindowState {
  const SavedWindowState({required this.bounds, this.maximized = false});
  final Rect bounds;
  final bool maximized;

  Map<String, dynamic> toJson() => {
    'x': bounds.left.round(),
    'y': bounds.top.round(),
    'w': bounds.width.round(),
    'h': bounds.height.round(),
    'max': maximized,
  };

  static SavedWindowState? fromJson(Object? j, {Size minimum = const Size(380, 640)}) {
    if (j is! Map) return null;
    double? n(String k) => j[k] is num ? (j[k] as num).toDouble() : null;
    final x = n('x'), y = n('y'), w = n('w'), h = n('h');
    if (x == null || y == null || w == null || h == null) return null;
    if (w < minimum.width || h < minimum.height || w > 20000 || h > 20000) return null;
    return SavedWindowState(
      bounds: Rect.fromLTWH(x, y, w, h),
      maximized: j['max'] == true,
    );
  }

  /// The saved bounds if a usable part of them (at least 120x60 logical px of
  /// the title area) lies on one of [displays]; otherwise null (e.g. the
  /// monitor it was on is gone).
  Rect? onScreenBounds(Iterable<Rect> displays) {
    for (final d in displays) {
      final i = bounds.intersect(d);
      if (!i.isEmpty && i.width >= 120 && i.height >= 60) return bounds;
    }
    return null;
  }
}
