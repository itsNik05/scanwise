import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/compress_provider.dart';
import '../providers/compress_state.dart';
import '../widgets/compress_result_card.dart';
import '../widgets/compression_level_selector.dart';

class CompressPdfPage extends ConsumerWidget {
  const CompressPdfPage({super.key});
//UI for COmpress PDf
  // ── Colors ──────────────────────────────────────────────────────────────
  static const _bg = Color(0xFF0D0D0F);
  static const _card = Color(0xFF131316);
  static const _card2 = Color(0xFF1A1A1F);
  static const _border = Color(0xFF2A2A35);
  static const _accent = Color(0xFFFF6B2B);
  static const _textPrimary = Color(0xFFF0EEE8);
  static const _textSecondary = Color(0xFF888899);
  static const _textMuted = Color(0xFF444455);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(compressPdfProvider);
    final notifier = ref.read(compressPdfProvider.notifier);

    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(context, notifier, state),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: state.status == CompressStatus.done && state.result != null
              ? _ResultView(state: state, notifier: notifier)
              : _MainView(state: state, notifier: notifier),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context,
      CompressNotifier notifier,
      CompressState state,
      ) {
    return AppBar(
      backgroundColor: _bg,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _card2,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _border),
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 16, color: _textSecondary),
        ),
      ),
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Compress PDF',
            style: TextStyle(
              fontFamily: 'Syne',
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: _textPrimary,
            ),
          ),
          Text(
            'Reduce file size without losing content',
            style: TextStyle(fontSize: 10, color: _textSecondary),
          ),
        ],
      ),
      actions: [
        if (state.status == CompressStatus.done)
          GestureDetector(
            onTap: notifier.reset,
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _card2,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _border),
              ),
              child: const Text(
                'New',
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _accent,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Main View (pick + configure + compress) ─────────────────────────────────

class _MainView extends StatelessWidget {
  final CompressState state;
  final CompressNotifier notifier;

  const _MainView({required this.state, required this.notifier});

  static const _bg = Color(0xFF0D0D0F);
  static const _card = Color(0xFF131316);
  static const _card2 = Color(0xFF1A1A1F);
  static const _border = Color(0xFF2A2A35);
  static const _accent = Color(0xFFFF6B2B);
  static const _textPrimary = Color(0xFFF0EEE8);
  static const _textSecondary = Color(0xFF888899);
  static const _textMuted = Color(0xFF444455);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── File Picker Area ────────────────────────────────────────
          _FilePicker(state: state, onPick: notifier.pickFile),
          const SizedBox(height: 24),

          // ── Compression Level ───────────────────────────────────────
          if (state.hasFile) ...[
            _SectionLabel(label: 'Compression Level'),
            const SizedBox(height: 12),
            CompressionLevelSelector(
              selected: state.level,
              onChanged: notifier.setLevel,
            ),
            const SizedBox(height: 24),
          ],

          // ── Progress (while compressing) ────────────────────────────
          if (state.isCompressing) ...[
            _ProgressSection(state: state),
            const SizedBox(height: 24),
          ],

          // ── Error ───────────────────────────────────────────────────
          if (state.status == CompressStatus.error &&
              state.errorMessage != null) ...[
            _ErrorBanner(message: state.errorMessage!),
            const SizedBox(height: 16),
          ],

          // ── Compress Button ─────────────────────────────────────────
          if (state.hasFile && !state.isCompressing)
            _CompressButton(onTap: notifier.compress),

          const SizedBox(height: 32),

          // ── Info Note ───────────────────────────────────────────────
          _InfoNote(),
        ],
      ),
    );
  }
}

// ── Result View ─────────────────────────────────────────────────────────────

class _ResultView extends StatelessWidget {
  final CompressState state;
  final CompressNotifier notifier;

  const _ResultView({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: CompressResultCard(
        result: state.result!,
        onShare: notifier.shareResult,
        onReset: notifier.reset,
      ),
    );
  }
}

// ── Sub-widgets ─────────────────────────────────────────────────────────────

class _FilePicker extends StatelessWidget {
  final CompressState state;
  final VoidCallback onPick;

  const _FilePicker({required this.state, required this.onPick});

  String _formatSize(int bytes) {
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  @override
  Widget build(BuildContext context) {
    if (state.hasFile) {
      // ── Selected file chip ──────────────────────────────────────────
      return GestureDetector(
        onTap: onPick,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF131316),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFF6B2B44), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1F),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF2A2A35)),
                ),
                child: const Center(
                  child: Text(
                    'PDF',
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFF6B2B),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.selectedFileName ?? '',
                      style: const TextStyle(
                        fontFamily: 'Syne',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFF0EEE8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      state.selectedFileSize != null
                          ? _formatSize(state.selectedFileSize!)
                          : '',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF888899),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1F),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF2A2A35)),
                ),
                child: const Text(
                  'Change',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF888899),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ── Drop / pick zone ────────────────────────────────────────────────
    return GestureDetector(
      onTap: onPick,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
        decoration: BoxDecoration(
          color: const Color(0xFF131316),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF2A2A35),
            style: BorderStyle.solid,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            const Text('🗜️', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 14),
            const Text(
              'Select a PDF to compress',
              style: TextStyle(
                fontFamily: 'Syne',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFFF0EEE8),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tap to browse files on your device',
              style: TextStyle(fontSize: 11, color: Color(0xFF888899)),
            ),
            const SizedBox(height: 20),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B2B),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B2B).withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Text(
                'Browse Files',
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0D0D0F),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontFamily: 'Syne',
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
        color: Color(0xFF888899),
      ),
    );
  }
}

class _ProgressSection extends StatelessWidget {
  final CompressState state;
  const _ProgressSection({required this.state});

  @override
  Widget build(BuildContext context) {
    final progress = state.progress;
    final label = state.totalPages > 0
        ? 'Processing page ${state.currentPage} of ${state.totalPages}…'
        : 'Preparing…';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF131316),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '🗜️  Compressing…',
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF0EEE8),
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFFF6B2B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress > 0 ? progress : null,
              backgroundColor: const Color(0xFF2A2A35),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFFF6B2B),
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF888899)),
          ),
        ],
      ),
    );
  }
}

class _CompressButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CompressButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFF6B2B),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6B2B).withOpacity(0.4),
              blurRadius: 24,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🗜️', style: TextStyle(fontSize: 18)),
            SizedBox(width: 10),
            Text(
              'Compress PDF',
              style: TextStyle(
                fontFamily: 'Syne',
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0D0D0F),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8717115),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF8717144)),
      ),
      child: Row(
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFFF87171),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF131316),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A35)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ℹ️  How compression works',
            style: TextStyle(
              fontFamily: 'Syne',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF888899),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Pages are rendered and re-encoded at a lower image quality. Text-heavy PDFs with few images will see minimal visual difference even at High compression.',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF444455),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}