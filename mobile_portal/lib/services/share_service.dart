import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../utils/app_theme.dart';
import '../widgets/share_card.dart';

class ShareService {
  /// Capture [card] off-screen via an Overlay + RepaintBoundary, then share PNG.
  static Future<void> _shareCard({
    required BuildContext context,
    required Widget card,
    required String shareText,
    required String filename,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (_) => const Center(child: CircularProgressIndicator(color: AppTheme.gold)),
    );

    try {
      final bytes = await _captureViaOverlay(context, card);
      final dir = await getTemporaryDirectory();
      final file = await File('${dir.path}/$filename').writeAsBytes(bytes);

      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        text: shareText,
        subject: 'From Qalaam',
      );
    } catch (e) {
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.error,
            content: Text('Could not share: $e', style: AppTheme.body(color: Colors.white)),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  static Future<Uint8List> _captureViaOverlay(BuildContext context, Widget card) async {
    final repaintKey = GlobalKey();
    final completer = Completer<void>();
    OverlayEntry? entry;
    entry = OverlayEntry(
      builder: (_) => Positioned(
        // Render off-screen but still in the tree.
        left: -10000,
        top: -10000,
        child: Material(
          color: Colors.transparent,
          child: RepaintBoundary(
            key: repaintKey,
            child: SizedBox(width: 1080, height: 1080, child: card),
          ),
        ),
      ),
    );
    Overlay.of(context, rootOverlay: true).insert(entry);

    // Wait two frames so layout/paint completes.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) => completer.complete());
    });
    await completer.future;

    try {
      final boundary = repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 1.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData!.buffer.asUint8List();
    } finally {
      entry.remove();
    }
  }

  // Public helpers ─────────────────────────────────────────────

  static Future<void> shareAyah({
    required BuildContext context,
    required String arabic,
    required String translation,
    required String reference,
  }) async {
    await _shareCard(
      context: context,
      card: ShareCard(arabic: arabic, translation: translation, reference: reference, kind: 'ayah'),
      shareText: '"$translation"\n— $reference\n\nFrom Qalaam · qalaam.co.tz',
      filename: 'qalaam-ayah-${DateTime.now().millisecondsSinceEpoch}.png',
    );
  }

  static Future<void> shareHadith({
    required BuildContext context,
    required String text,
    required String reference,
    String? arabic,
  }) async {
    await _shareCard(
      context: context,
      card: ShareCard(arabic: arabic, translation: text, reference: reference, kind: 'hadith'),
      shareText: '"$text"\n— $reference\n\nFrom Qalaam · qalaam.co.tz',
      filename: 'qalaam-hadith-${DateTime.now().millisecondsSinceEpoch}.png',
    );
  }

  static Future<void> shareDhikr({
    required BuildContext context,
    required String arabic,
    required String name,
    required String translation,
  }) async {
    await _shareCard(
      context: context,
      card: ShareCard(arabic: arabic, translation: translation, reference: name, kind: 'dhikr'),
      shareText: '$name\n"$translation"\n\nFrom Qalaam · qalaam.co.tz',
      filename: 'qalaam-dhikr-${DateTime.now().millisecondsSinceEpoch}.png',
    );
  }
}
