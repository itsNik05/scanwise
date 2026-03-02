import 'package:flutter/material.dart';

import '../../domain/entities/compress_result.dart';

class CompressResultCard extends StatelessWidget {
  final CompressResult result;
  final VoidCallback onShare;
  final VoidCallback onReset;

  const CompressResultCard({
    super.key,
    required this.result,
    required this.onShare,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final saved = (result.compressionRatio * 100).toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF131316),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF4ADE8044), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4ADE80).withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF4ADE80).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF4ADE80).withOpacity(0.3),
                  ),
                ),
                child: const Center(
                  child: Text('✅', style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Compression Complete',
                      style: TextStyle(
                        fontFamily: 'Syne',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFF0EEE8),
                      ),
                    ),
                    Text(
                      result.fileName,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF888899),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Size comparison ───────────────────────────────────────────
          Row(
            children: [
              _SizeChip(
                label: 'Before',
                value: result.originalSizeFormatted,
                color: const Color(0xFF888899),
              ),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [
                          Color(0xFF888899),
                          Color(0xFF4ADE80),
                        ]),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4ADE80).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFF4ADE80).withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        '-$saved%',
                        style: const TextStyle(
                          fontFamily: 'Syne',
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF4ADE80),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _SizeChip(
                label: 'After',
                value: result.compressedSizeFormatted,
                color: const Color(0xFF4ADE80),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Saved bytes ───────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1F),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('💾', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Text(
                  'You saved ${result.savedBytesFormatted} of storage',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888899),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Actions ───────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: 'Share',
                  icon: '📤',
                  isPrimary: true,
                  onTap: onShare,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionButton(
                  label: 'Compress Another',
                  icon: '🔄',
                  isPrimary: false,
                  onTap: onReset,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SizeChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SizeChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Syne',
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF444455)),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final String icon;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isPrimary
              ? const Color(0xFFFF6B2B)
              : const Color(0xFF1A1A1F),
          borderRadius: BorderRadius.circular(12),
          border: isPrimary
              ? null
              : Border.all(color: const Color(0xFF2A2A35)),
          boxShadow: isPrimary
              ? [
            BoxShadow(
              color: const Color(0xFFFF6B2B).withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 4),
            )
          ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isPrimary
                      ? const Color(0xFF0D0D0F)
                      : const Color(0xFFF0EEE8),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}