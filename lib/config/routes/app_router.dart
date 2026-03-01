/// ------------------------------------------------------------
/// AppRouter
/// ------------------------------------------------------------
/// Central routing configuration using go_router.
/// ------------------------------------------------------------

import 'package:go_router/go_router.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import 'route_names.dart';

import '../../features/files/presentation/pages/files_page.dart';
import '../../features/files/presentation/pages/pdf_preview_page.dart';
import '../../features/folders/presentation/pages/folders_page.dart';


import '../../features/scan_pdf/presentation/pages/scan_camera_page.dart';
import '../../features/scan_pdf/presentation/pages/scan_preview_page.dart';
import '../../features/scan_pdf/presentation/pages/scan_save_page.dart';



final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: RouteNames.dashboard,
      builder: (context, state) => const DashboardPage(),
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
        final data = state.extra as Map<String, String>;

        return PdfPreviewPage(
          path: data['path']!,
          name: data['name']!,
        );
      },
    ),

    GoRoute(
      path: RouteNames.scanCamera,
      builder: (context, state) => const ScanCameraPage(),
    ),

    GoRoute(
      path: RouteNames.folders,
      builder: (context, state) => const FoldersPage(),
    ),

    GoRoute(
      path: RouteNames.scanSave,
      builder: (context, state) => const ScanSavePage(),
    ),

  ],
);