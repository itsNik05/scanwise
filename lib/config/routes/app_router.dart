/// ------------------------------------------------------------
/// AppRouter
/// ------------------------------------------------------------
/// Central routing configuration using go_router.
/// ------------------------------------------------------------

import 'package:go_router/go_router.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import 'route_names.dart';
import '../../features/scan_pdf/presentation/pages/scan_page.dart';
import '../../features/files/presentation/pages/files_page.dart';
import '../../features/files/presentation/pages/pdf_preview_page.dart';
import '../../features/folders/presentation/pages/folders_page.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: RouteNames.dashboard,
      builder: (context, state) => const DashboardPage(),
    ),
    GoRoute(
      path: RouteNames.scan,
      builder: (context, state) => const ScanPage(),
    ),
    GoRoute(
      path: RouteNames.files,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;

        final folderPath = extra?['path'] as String?;
        final folderName = extra?['name'] as String?;

        return FilesPage(
          folderPath: folderPath,
          folderName: folderName,
        );
      },
    ),
    GoRoute(
      path: RouteNames.pdfPreview,
      builder: (context, state) {
        final filePath = state.extra as String;
        return PdfPreviewPage(filePath: filePath);
      },
    ),

    GoRoute(
      path: RouteNames.folders,
      builder: (context, state) => const FoldersPage(),
    ),

  ],
);