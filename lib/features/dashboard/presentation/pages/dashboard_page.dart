/// features/dashboard/presentation/pages/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/progress_bar.dart';
import '../widgets/stat_chip.dart';
import '../widgets/upload_zone.dart';
import '../widgets/quick_tools_section.dart';
import '../widgets/power_tools_section.dart';
import '../widgets/recent_files_section.dart';
import '../widgets/bottom_navigation.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardProvider);
    final dashboardNotifier = ref.read(dashboardProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: SafeArea(
        child: Stack(
          children: [
            // Main scrollable content
            CustomScrollView(
              slivers: [
                // ── Header ─────────────────────────────────────
                const SliverToBoxAdapter(
                  child: DashboardHeader(),
                ),

                // ── Stats Row ──────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        StatChip(
                          value: dashboardState.stats.filesCount.toString(),
                          label: 'Files',
                          delayMs: 0,
                        ),
                        const SizedBox(width: 8),
                        StatChip(
                          value: dashboardState.stats.storageMb,
                          label: 'Saved',
                          delayMs: 50,
                        ),
                        const SizedBox(width: 8),
                        StatChip(
                          value: dashboardState.stats.tasksCount.toString(),
                          label: 'Tasks',
                          delayMs: 100,
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 8)),

                // ── Storage Progress ──────────────────────────
                SliverToBoxAdapter(
                  child: ProgressBar(
                    percentage: dashboardState.storageProgress,
                    label:
                    'Storage used · ${dashboardState.stats.storagePercentage}%',
                    sublabel: dashboardState.stats.storageLimitGb,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                // ── Upload Zone ────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: UploadZone(
                      onTap: () {
                        context.push('/scan');
                      },
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                // ── Quick Tools Section ────────────────────────
                SliverToBoxAdapter(
                  child: QuickToolsSection(
                    tools: dashboardState.quickTools,
                    onToolTap: (tool) {
                      context.push(tool.route);
                    },
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                // ── Power Tools Section ────────────────────────
                SliverToBoxAdapter(
                  child: PowerToolsSection(
                    tools: dashboardState.powerTools,
                    onToolTap: (tool) {
                      context.push(tool.route);
                    },
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                // ── Recent Files Section ───────────────────────
                SliverToBoxAdapter(
                  child: RecentFilesSection(
                    files: dashboardState.recentFiles,
                    onFileTap: (file) {
                      // Navigate to PDF preview
                      context.push(
                        '/pdf-preview',
                        extra: {
                          'path': file.filePath,
                          'name': file.name,
                        },
                      );
                    },
                    onShare: (file) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Sharing ${file.name}...'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    onMore: (file) {
                      // Show bottom sheet with more options
                      _showFileActions(context, file.name);
                    },
                  ),
                ),

                // ── Bottom padding for FAB ─────────────────────
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),

            // ── Bottom Navigation (Fixed) ──────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BottomNavigation(
                selectedIndex: dashboardState.selectedNavIndex,
                onTap: (index) {
                  dashboardNotifier.selectNavItem(index);
                  // Navigate based on index
                  switch (index) {
                    case 0:
                      context.go('/');
                      break;
                    case 1:
                      context.push('/files');
                      break;
                    case 2:
                      context.push('/starred');
                      break;
                    case 3:
                      context.push('/profile');
                      break;
                  }
                },
                onFabPressed: () {
                  // Show FAB menu
                  _showFabMenu(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFileActions(BuildContext context, String fileName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              fileName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _ActionTile(
              icon: '📋',
              label: 'Copy',
              onTap: () => Navigator.pop(context),
            ),
            _ActionTile(
              icon: '✏️',
              label: 'Rename',
              onTap: () => Navigator.pop(context),
            ),
            _ActionTile(
              icon: '🗑️',
              label: 'Delete',
              onTap: () => Navigator.pop(context),
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  void _showFabMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Create New',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _ActionTile(
              icon: '📷',
              label: 'Scan Document',
              onTap: () {
                Navigator.pop(context);
                context.push('/scan');
              },
            ),
            _ActionTile(
              icon: '📁',
              label: 'Create Folder',
              onTap: () => Navigator.pop(context),
            ),
            _ActionTile(
              icon: '📤',
              label: 'Upload Files',
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isDestructive
              ? AppColors.error.withOpacity(0.1)
              : AppColors.bgCard2,
          border: Border.all(
            color: isDestructive
                ? AppColors.error.withOpacity(0.3)
                : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color:
                isDestructive ? AppColors.error : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}