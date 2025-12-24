import 'dart:async';
import 'package:flutter/services.dart';

/// A service class for interacting with the system clipboard.
///
/// This service handles copying data to the clipboard and automatically
/// clearing sensitive data after a specified duration to enhance security.
class ClipboardService {
  Timer? _clearTimer;

  /// Copies the provided [text] to the system clipboard.
  ///
  /// If [isSensitive] is true, the clipboard content will be cleared after
  /// the duration specified by [clearAfter].
  ///
  /// [text] The text to copy.
  /// [isSensitive] Whether the data is sensitive (e.g., password). Defaults to `true`.
  /// [clearAfter] The duration to wait before clearing the clipboard. Defaults to 30 seconds.
  Future<void> copy(String text, {bool isSensitive = true, Duration clearAfter = const Duration(seconds: 30)}) async {
    await Clipboard.setData(ClipboardData(text: text));

    _clearTimer?.cancel();
    if (isSensitive) {
      _clearTimer = Timer(clearAfter, () async {
        // Only clear if the current clipboard content is still the sensitive one.
        // This is a bit tricky on some platforms, so we just clear it.
        await Clipboard.setData(const ClipboardData(text: ''));
      });
    }
  }

  /// Cancels the sensitive data clear timer if it is active.
  void dispose() {
    _clearTimer?.cancel();
  }
}
