import 'package:flutter/material.dart';

import '../../domain/entities/merged_document.dart';

class MergeResultCard extends StatelessWidget {
  final MergedDocument result;
  final VoidCallback onShare;
  final VoidCallback onReset;

  const MergeResultCard({
    super.key,
    required this.result,
    required this.onShare,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF131316),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF60A5FA).withOpacity(0.27), width: 1.5),
        boxShadow: [
          BoxShadow(color: const Color(0xFF60A5FA).withOpacity(0.07), blurRadius: 24, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF60A5FA).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF60A5FA).withOpacity(0.3)),
                ),
                child: const Center(child: Text('✅', style: TextStyle(fontSize: 18))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Merge Complete',
                      style: TextStyle(fontFamily: 'Syne', fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFFF0EEE8))),
                    Text(result.outputName,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF888899)),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _StatChip(icon: '📄', label: 'Files merged', value: '${result.fileCount}', color: const Color(0xFF60A5FA)),
              const SizedBox(width: 10),
              _StatChip(icon: '📑', label: 'Total pages', value: '${result.totalPages}', color: const Color(0xFFFF6B2B)),
              const SizedBox(width: 10),
              _StatChip(icon: '💾', label: 'Output size', value: result.outputSizeFormatted, color: const Color(0xFF4ADE80)),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFF1A1A1F), borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                const Text('🔗', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(result.outputName,
                    style: const TextStyle(fontFamily: 'Syne', fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFF0EEE8)),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _ActionButton(label: 'Share', icon: '📤', isPrimary: true, onTap: onShare)),
              const SizedBox(width: 10),
              Expanded(child: _ActionButton(label: 'Merge Again', icon: '🔗', isPrimary: false, onTap: onReset)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;
  const _StatChip({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontFamily: 'Syne', fontSize: 15, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 2),
            Text(label,
              style: const TextStyle(fontSize: 9, color: Color(0xFF888899), letterSpacing: 0.3),
              textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final String icon;
  final bool isPrimary;
  final VoidCallback onTap;
  const _ActionButton({required this.label, required this.icon, required this.isPrimary, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFFFF6B2B) : const Color(0xFF1A1A1F),
          borderRadius: BorderRadius.circular(12),
          border: isPrimary ? null : Border.all(color: const Color(0xFF2A2A35)),
          boxShadow: isPrimary
              ? [BoxShadow(color: const Color(0xFFFF6B2B).withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 4))]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(label,
                style: TextStyle(
                  fontFamily: 'Syne', fontSize: 12, fontWeight: FontWeight.w700,
                  color: isPrimary ? const Color(0xFF0D0D0F) : const Color(0xFFF0EEE8)),
                overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}
