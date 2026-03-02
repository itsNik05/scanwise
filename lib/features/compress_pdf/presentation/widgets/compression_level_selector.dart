import 'package:flutter/material.dart';

import '../../domain/entities/compression_level.dart';

class CompressionLevelSelector extends StatelessWidget {
  final CompressionLevel selected;
  final ValueChanged<CompressionLevel> onChanged;

  const CompressionLevelSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: CompressionLevel.values
          .map((level) => _LevelTile(
        level: level,
        isSelected: selected == level,
        onTap: () => onChanged(level),
      ))
          .toList(),
    );
  }
}

class _LevelTile extends StatelessWidget {
  final CompressionLevel level;
  final bool isSelected;
  final VoidCallback onTap;

  const _LevelTile({
    required this.level,
    required this.isSelected,
    required this.onTap,
  });

  Color get _accentColor {
    switch (level) {
      case CompressionLevel.low:
        return const Color(0xFF4ADE80); // green — mild
      case CompressionLevel.medium:
        return const Color(0xFFFF6B2B); // orange — balanced
      case CompressionLevel.high:
        return const Color(0xFFF87171); // red — aggressive
    }
  }

  String get _icon {
    switch (level) {
      case CompressionLevel.low:
        return '🟢';
      case CompressionLevel.medium:
        return '🟠';
      case CompressionLevel.high:
        return '🔴';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _accentColor;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.1)
              : const Color(0xFF131316),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color.withOpacity(0.6) : const Color(0xFF2A2A35),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Leading icon / radio
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? color : const Color(0xFF444455),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                  ),
                ),
              )
                  : null,
            ),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '$_icon  ${level.label}',
                        style: TextStyle(
                          fontFamily: 'Syne',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? color : const Color(0xFFF0EEE8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    level.description,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF888899),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}