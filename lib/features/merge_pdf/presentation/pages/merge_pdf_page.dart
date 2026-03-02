import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/merge_provider.dart';
import '../providers/merge_state.dart';
import '../widgets/merge_result_card.dart';
import '../widgets/selected_files_list.dart';

class MergePdfPage extends ConsumerWidget {
  const MergePdfPage({super.key});

  static const _bg            = Color(0xFF0D0D0F);
  static const _card2         = Color(0xFF1A1A1F);
  static const _border        = Color(0xFF2A2A35);
  static const _accent        = Color(0xFFFF6B2B);
  static const _textPrimary   = Color(0xFFF0EEE8);
  static const _textSecondary = Color(0xFF888899);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state    = ref.watch(mergePdfProvider);
    final notifier = ref.read(mergePdfProvider.notifier);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _card2, borderRadius: BorderRadius.circular(10), border: Border.all(color: _border)),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: _textSecondary),
          ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Merge PDFs',
              style: TextStyle(fontFamily: 'Syne', fontSize: 17, fontWeight: FontWeight.w800, color: _textPrimary)),
            Text('Combine multiple PDFs into one',
              style: TextStyle(fontSize: 10, color: _textSecondary)),
          ],
        ),
        actions: [
          if (state.status == MergeStatus.done)
            GestureDetector(
              onTap: notifier.reset,
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _card2, borderRadius: BorderRadius.circular(8), border: Border.all(color: _border)),
                child: const Text('New',
                  style: TextStyle(fontFamily: 'Syne', fontSize: 12, fontWeight: FontWeight.w700, color: _accent)),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: state.status == MergeStatus.done && state.result != null
              ? _ResultView(state: state, notifier: notifier)
              : _MainView(state: state, notifier: notifier),
        ),
      ),
    );
  }
}

class _MainView extends StatelessWidget {
  final MergeState state;
  final MergeNotifier notifier;
  const _MainView({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AddFilesButton(
            fileCount: state.selectedFiles.length,
            onTap: notifier.pickFiles,
            isLoading: state.status == MergeStatus.picking,
          ),
          if (state.hasFiles) ...[
            const SizedBox(height: 20),
            _SectionLabel(
              label: 'Selected Files',
              trailing: '${state.selectedFiles.length} files'
                  '${state.totalSelectedPages > 0 ? ' · ${state.totalSelectedPages} pages' : ''}',
            ),
            const SizedBox(height: 10),
            SelectedFilesList(
              files: state.selectedFiles,
              onRemove: notifier.removeFile,
              onReorder: notifier.reorderFiles,
            ),
          ],
          if (state.canMerge) ...[
            const SizedBox(height: 20),
            const _SectionLabel(label: 'Output File Name'),
            const SizedBox(height: 10),
            _OutputNameField(initialValue: state.outputName, onChanged: notifier.setOutputName),
          ],
          if (state.isMerging) ...[
            const SizedBox(height: 20),
            _ProgressSection(state: state),
          ],
          if (state.status == MergeStatus.error && state.errorMessage != null) ...[
            const SizedBox(height: 16),
            _ErrorBanner(message: state.errorMessage!),
          ],
          if (state.canMerge && !state.isMerging) ...[
            const SizedBox(height: 24),
            _MergeButton(onTap: notifier.merge),
          ],
          if (state.hasFiles && !state.canMerge && !state.isMerging) ...[
            const SizedBox(height: 16),
            _HintBanner(),
          ],
          const SizedBox(height: 32),
          _InfoNote(),
        ],
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  final MergeState state;
  final MergeNotifier notifier;
  const _ResultView({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: MergeResultCard(result: state.result!, onShare: notifier.shareResult, onReset: notifier.reset),
    );
  }
}

class _AddFilesButton extends StatelessWidget {
  final int fileCount;
  final VoidCallback onTap;
  final bool isLoading;
  const _AddFilesButton({required this.fileCount, required this.onTap, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (fileCount == 0) {
      return GestureDetector(
        onTap: isLoading ? null : onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
          decoration: BoxDecoration(
            color: const Color(0xFF131316),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF2A2A35), width: 1.5),
          ),
          child: Column(
            children: [
              const Text('🔗', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 14),
              const Text('Select PDFs to merge',
                style: TextStyle(fontFamily: 'Syne', fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFFF0EEE8))),
              const SizedBox(height: 6),
              const Text('Choose 2 or more PDF files in any order',
                style: TextStyle(fontSize: 11, color: Color(0xFF888899))),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B2B),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: const Color(0xFFFF6B2B).withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 4))],
                ),
                child: isLoading
                    ? const SizedBox(width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0D0D0F)))
                    : const Text('Browse Files',
                        style: TextStyle(fontFamily: 'Syne', fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0D0D0F))),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF131316),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFF6B2B).withOpacity(0.35), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B2B).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(child: Text('+', style: TextStyle(fontSize: 18, color: Color(0xFFFF6B2B)))),
            ),
            const SizedBox(width: 10),
            const Text('Add More PDFs',
              style: TextStyle(fontFamily: 'Syne', fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFFF6B2B))),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final String? trailing;
  const _SectionLabel({required this.label, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label.toUpperCase(),
          style: const TextStyle(fontFamily: 'Syne', fontSize: 11, fontWeight: FontWeight.w700,
            letterSpacing: 1.5, color: Color(0xFF888899))),
        if (trailing != null)
          Text(trailing!, style: const TextStyle(fontSize: 11, color: Color(0xFF444455))),
      ],
    );
  }
}

class _OutputNameField extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;
  const _OutputNameField({required this.initialValue, required this.onChanged});

  @override
  State<_OutputNameField> createState() => _OutputNameFieldState();
}

class _OutputNameFieldState extends State<_OutputNameField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF131316),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A2A35)),
      ),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        style: const TextStyle(fontFamily: 'Syne', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFF0EEE8)),
        decoration: const InputDecoration(
          hintText: 'e.g. merged_contract  (optional)',
          hintStyle: TextStyle(fontSize: 12, color: Color(0xFF444455)),
          suffixText: '.pdf',
          suffixStyle: TextStyle(fontSize: 12, color: Color(0xFF888899)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        cursorColor: const Color(0xFFFF6B2B),
      ),
    );
  }
}

class _ProgressSection extends StatelessWidget {
  final MergeState state;
  const _ProgressSection({required this.state});

  @override
  Widget build(BuildContext context) {
    final progress = state.progress;
    final label = state.totalPages > 0
        ? 'Processing page \${state.currentPage} of \${state.totalPages}…'
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
              const Text('🔗  Merging…',
                style: TextStyle(fontFamily: 'Syne', fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFF0EEE8))),
              Text('\${(progress * 100).toInt()}%',
                style: const TextStyle(fontFamily: 'Syne', fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFFFF6B2B))),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress > 0 ? progress : null,
              backgroundColor: const Color(0xFF2A2A35),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF6B2B)),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF888899))),
        ],
      ),
    );
  }
}

class _MergeButton extends StatelessWidget {
  final VoidCallback onTap;
  const _MergeButton({required this.onTap});

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
          boxShadow: [BoxShadow(color: const Color(0xFFFF6B2B).withOpacity(0.4), blurRadius: 24, offset: const Offset(0, 6))],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🔗', style: TextStyle(fontSize: 18)),
            SizedBox(width: 10),
            Text('Merge PDFs',
              style: TextStyle(fontFamily: 'Syne', fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0D0D0F))),
          ],
        ),
      ),
    );
  }
}

class _HintBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF60A5FA).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF60A5FA).withOpacity(0.25)),
      ),
      child: const Row(
        children: [
          Text('💡', style: TextStyle(fontSize: 14)),
          SizedBox(width: 10),
          Expanded(
            child: Text('Add at least one more PDF to enable merging.',
              style: TextStyle(fontSize: 12, color: Color(0xFF60A5FA))),
          ),
        ],
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
        color: const Color(0xFFF87171).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF87171).withOpacity(0.27)),
      ),
      child: Row(
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: const TextStyle(fontSize: 12, color: Color(0xFFF87171)))),
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
          Text('ℹ️  Tips',
            style: TextStyle(fontFamily: 'Syne', fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF888899))),
          SizedBox(height: 8),
          Text(
            '• Drag the ≡ handle to reorder files before merging.\n'
            '• The output order matches the list from top to bottom.\n'
            '• The output name is optional — a timestamp is used if left blank.',
            style: TextStyle(fontSize: 11, color: Color(0xFF444455), height: 1.7),
          ),
        ],
      ),
    );
  }
}
