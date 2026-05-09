import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../utils/app_theme.dart';
import '../services/api_service.dart';
import '../services/share_service.dart';
import '../models/app_models.dart';
import '../widgets/qalaam_card.dart';
import '../widgets/shimmer.dart';

class FatwaScreen extends StatefulWidget {
  const FatwaScreen({super.key});

  @override
  State<FatwaScreen> createState() => _FatwaScreenState();
}

class _FatwaScreenState extends State<FatwaScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Fatwa>> _future;

  @override
  void initState() {
    super.initState();
    _future = _apiService.fetchFatawa();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Ask a scholar')),
      body: FutureBuilder<List<Fatwa>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SkeletonList(count: 5, itemHeight: 130);
          }
          final list = snapshot.data ?? const <Fatwa>[];
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildIntro()),
              if (list.isEmpty)
                SliverToBoxAdapter(child: _empty())
              else
                SliverList.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppTheme.space3),
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.space5),
                    child: _fatwaCard(list[i]),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppTheme.primaryGreen,
        icon: const Icon(Icons.edit_outlined, color: Colors.white),
        label: const Text('Ask question'),
      ),
    );
  }

  Widget _buildIntro() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppTheme.space5, AppTheme.space3, AppTheme.space5, AppTheme.space5),
      child: QalaamCard(
        padding: const EdgeInsets.all(AppTheme.space5),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.accentGold,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.help_outline_rounded, color: AppTheme.gold, size: 26),
            ),
            const SizedBox(width: AppTheme.space4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Verified scholarly answers', style: AppTheme.h3()),
                  const SizedBox(height: 2),
                  Text('Browse questions or submit your own. Answered by qualified scholars.',
                      style: AppTheme.caption()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openAnswer(Fatwa f) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.86,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.borderLight,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(AppTheme.space5, AppTheme.space4, AppTheme.space5, AppTheme.space2),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGreen,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text((f.category.isNotEmpty ? f.category : 'GENERAL').toUpperCase(),
                          style: AppTheme.eyebrow().copyWith(fontSize: 10)),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.share_outlined, size: 20, color: AppTheme.textGrey),
                      onPressed: () => ShareService.shareHadith(
                        context: context,
                        text: f.question,
                        reference: f.scholar.isNotEmpty ? f.scholar : 'Scholar',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 22, color: AppTheme.textDark),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(AppTheme.space5, 0, AppTheme.space5, AppTheme.space7),
                  children: [
                    Text('Question', style: AppTheme.eyebrow()),
                    const SizedBox(height: 8),
                    Text(f.question, style: AppTheme.h2().copyWith(fontSize: 19, height: 1.35)),
                    const SizedBox(height: AppTheme.space5),
                    Container(height: 1, color: AppTheme.borderLight),
                    const SizedBox(height: AppTheme.space5),
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: AppTheme.gradientPrimary,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.auto_awesome_rounded, size: 16, color: AppTheme.gold),
                        ),
                        const SizedBox(width: 10),
                        Text('Scholar\'s answer', style: AppTheme.eyebrow()),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (f.answer.trim().isNotEmpty)
                      Html(
                        data: f.answer,
                        style: {
                          'body': Style(
                            fontFamily: 'Manrope',
                            fontSize: FontSize(15),
                            color: AppTheme.textBody,
                            lineHeight: const LineHeight(1.6),
                            margin: Margins.zero,
                          ),
                          'p': Style(margin: Margins.only(bottom: 14)),
                        },
                      )
                    else
                      Text('No answer available yet.',
                          style: AppTheme.body().copyWith(fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fatwaCard(Fatwa f) {
    return QalaamTappableCard(
      padding: const EdgeInsets.all(AppTheme.space4),
      onTap: () => _openAnswer(f),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text((f.category.isNotEmpty ? f.category : 'GENERAL').toUpperCase(),
                    style: AppTheme.eyebrow().copyWith(fontSize: 9, letterSpacing: 1.2)),
              ),
              const Spacer(),
              const Icon(Icons.bookmark_outline_rounded, color: AppTheme.textMuted, size: 18),
            ],
          ),
          const SizedBox(height: AppTheme.space3),
          Text(f.question, style: AppTheme.h3(), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          Text(f.answer.isNotEmpty ? f.answer : 'Tap to view scholarly response',
              style: AppTheme.body(), maxLines: 3, overflow: TextOverflow.ellipsis),
          const SizedBox(height: AppTheme.space3),
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: AppTheme.parchment,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: const Icon(Icons.person_outline_rounded, color: AppTheme.primaryGreen, size: 14),
              ),
              const SizedBox(width: 8),
              Text(f.scholar.isNotEmpty ? f.scholar : 'Scholar', style: AppTheme.caption()),
              const Spacer(),
              Text('Read answer', style: AppTheme.caption(color: AppTheme.primaryGreen).copyWith(fontWeight: FontWeight.w800)),
              const Icon(Icons.arrow_forward_rounded, color: AppTheme.primaryGreen, size: 16),
            ],
          ),
        ],
      ),
    );
  }

  Widget _empty() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: QalaamCard(
        padding: const EdgeInsets.all(AppTheme.space7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.help_outline_rounded, color: AppTheme.textGrey, size: 38),
            const SizedBox(height: 12),
            Text('No answered questions yet', style: AppTheme.h3(), textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text('Be the first to ask.', style: AppTheme.caption()),
          ],
        ),
      ),
    );
  }
}
