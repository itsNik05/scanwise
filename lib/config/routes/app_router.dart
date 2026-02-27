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
      builder: (context, state) => const FilesPage(),
    ),
  ],
);