/// ------------------------------------------------------------
/// DashboardPage
/// ------------------------------------------------------------
/// Home screen of ScanWise.
/// Will contain navigation to all tools.
/// ------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/routes/route_names.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ScanWise")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "ScanWise",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text("PDF Scanner & Tools"),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () => context.go(RouteNames.scan),
              child: const Text("Scan Document"),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () => context.go(RouteNames.files),
              child: const Text("View Scanned Files"),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () =>
                  context.go(RouteNames.folders),
              child: const Text("Manage Folders"),
            ),
          ],
        ),
      ),
    );
  }
}