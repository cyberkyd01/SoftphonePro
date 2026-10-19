import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../l10n/l10n.dart';

/// Builds the live camera preview; calls [onCode] for every decoded QR text.
typedef QrCameraBuilder = Widget Function(BuildContext context, ValueChanged<String> onCode);

/// Camera scanning is available on Android, iOS and macOS only.
bool get qrCameraSupported => Platform.isAndroid || Platform.isIOS || Platform.isMacOS;

/// Shows the scanner as a bottom sheet and returns the scanned or pasted
/// text (null when dismissed). Always offers a paste fallback.
Future<String?> showQrScannerSheet(
  BuildContext context, {
  String? title,
  String? pasteHint,
  QrCameraBuilder? cameraBuilder,
  bool? cameraSupported,
}) => showModalBottomSheet<String>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: true,
  builder: (_) => QrScannerSheet(
    title: title,
    pasteHint: pasteHint,
    cameraBuilder: cameraBuilder,
    cameraSupported: cameraSupported ?? qrCameraSupported,
  ),
);

class QrScannerSheet extends StatefulWidget {
  const QrScannerSheet({
    super.key,
    this.title,
    this.pasteHint,
    this.cameraBuilder,
    required this.cameraSupported,
  });
  final String? title;
  final String? pasteHint;
  final QrCameraBuilder? cameraBuilder;
  final bool cameraSupported;

  @override
  State<QrScannerSheet> createState() => _QrScannerSheetState();
}

class _QrScannerSheetState extends State<QrScannerSheet> {
  final _text = TextEditingController();
  bool _done = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _finish(String code) {
    if (_done || code.trim().isEmpty) return;
    _done = true;
    Navigator.of(context).pop(code.trim());
  }

  Widget _camera(BuildContext context) {
    final b = widget.cameraBuilder;
    if (b != null) return b(context, _finish);
    return _LiveCamera(onCode: _finish);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.title ?? context.l10n.uiQrScanTitle, style: t.textTheme.titleLarge),
            const SizedBox(height: 12),
            if (widget.cameraSupported)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(key: const Key('qr-camera'), height: 280, child: _camera(context)),
              )
            else
              Text(
                context.l10n.uiQrNoCamera,
                key: const Key('qr-no-camera'),
                style: t.textTheme.bodyMedium?.copyWith(color: t.colorScheme.onSurfaceVariant),
              ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('qr-paste-field'),
              controller: _text,
              minLines: 1,
              maxLines: 4,
              decoration: InputDecoration(hintText: widget.pasteHint ?? context.l10n.uiQrPasteHint, prefixIcon: const Icon(Icons.content_paste_rounded)),
              onSubmitted: _finish,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton.icon(
                  key: const Key('qr-paste-clipboard'),
                  onPressed: () async {
                    final d = await Clipboard.getData(Clipboard.kTextPlain);
                    if (d?.text != null) setState(() => _text.text = d!.text!);
                  },
                  icon: const Icon(Icons.paste_rounded),
                  label: Text(context.l10n.uiQrPaste),
                ),
                const Spacer(),
                TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.actionCancel)),
                const SizedBox(width: 8),
                FilledButton(key: const Key('qr-use-text'), onPressed: () => _finish(_text.text), child: Text(context.l10n.uiQrUse)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveCamera extends StatefulWidget {
  const _LiveCamera({required this.onCode});
  final ValueChanged<String> onCode;
  @override
  State<_LiveCamera> createState() => _LiveCameraState();
}

class _LiveCameraState extends State<_LiveCamera> {
  final _controller = MobileScannerController(formats: const [BarcodeFormat.qrCode]);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MobileScanner(
      controller: _controller,
      onDetect: (capture) {
        for (final b in capture.barcodes) {
          final v = b.rawValue;
          if (v != null && v.isNotEmpty) {
            widget.onCode(v);
            return;
          }
        }
      },
      errorBuilder: (context, error, _) {
        final denied = error.errorCode == MobileScannerErrorCode.permissionDenied;
        return ColoredBox(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                denied ? context.l10n.uiQrCameraDenied : context.l10n.uiQrCameraUnavailable,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }
}
