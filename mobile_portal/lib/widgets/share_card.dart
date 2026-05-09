import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import 'geometric_pattern.dart';

/// A styled card for share-as-image. Renders deterministically off-screen.
class ShareCard extends StatelessWidget {
  final String? arabic;
  final String? translation;
  final String reference;
  final String kind; // "ayah" | "hadith" | "dhikr" | "quote"

  const ShareCard({
    super.key,
    this.arabic,
    this.translation,
    required this.reference,
    this.kind = 'ayah',
  });

  String get _eyebrowLabel => switch (kind) {
        'hadith' => 'HADITH',
        'dhikr' => 'DHIKR',
        'quote' => 'WISDOM',
        _ => 'AYAH',
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1080,
      height: 1080,
      decoration: const BoxDecoration(gradient: AppTheme.gradientHero),
      child: Stack(
        children: [
          const Positioned.fill(child: GeometricPattern(opacity: 0.08, cell: 90)),
          Positioned(
            top: -120,
            right: -120,
            child: Container(
              width: 480,
              height: 480,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [AppTheme.gold.withOpacity(0.18), Colors.transparent]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Colors.white, AppTheme.parchment]),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.menu_book_rounded, color: AppTheme.primaryGreen, size: 32),
                    ),
                    const SizedBox(width: 18),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('QALAAM',
                            style: GoogleFonts.manrope(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 4,
                              color: Colors.white,
                            )),
                        const SizedBox(height: 2),
                        Text('A scholarly bridge',
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              color: AppTheme.gold,
                              letterSpacing: 1.6,
                              fontWeight: FontWeight.w600,
                            )),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppTheme.gold.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(color: AppTheme.gold.withOpacity(0.45), width: 1),
                      ),
                      child: Text(_eyebrowLabel,
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.4,
                            color: AppTheme.gold,
                          )),
                    ),
                  ],
                ),
                const Spacer(),
                if (arabic != null && arabic!.isNotEmpty) ...[
                  Text(
                    arabic!,
                    textAlign: TextAlign.right,
                    style: GoogleFonts.amiri(
                      fontSize: 56,
                      height: 1.85,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 36),
                ],
                if (translation != null && translation!.isNotEmpty)
                  Text(
                    '"${translation!}"',
                    style: GoogleFonts.manrope(
                      fontSize: 30,
                      height: 1.5,
                      color: Colors.white.withOpacity(0.92),
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                const Spacer(),
                Row(
                  children: [
                    Container(width: 34, height: 2, color: AppTheme.gold),
                    const SizedBox(width: 14),
                    Text(reference,
                        style: GoogleFonts.manrope(
                          fontSize: 22,
                          color: AppTheme.gold,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        )),
                    const Spacer(),
                    Text('qalaam.co.tz',
                        style: GoogleFonts.manrope(
                          fontSize: 18,
                          color: Colors.white.withOpacity(0.55),
                          fontWeight: FontWeight.w500,
                        )),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
