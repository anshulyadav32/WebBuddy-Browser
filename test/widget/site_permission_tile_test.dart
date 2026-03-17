import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:web_buddy/features/settings/domain/site_permission.dart';
import 'package:web_buddy/features/settings/presentation/widgets/site_permission_tile.dart';

void main() {
  group('SitePermissionTile', () {
    testWidgets('permission name visible', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SitePermissionTile(
              permission: const SitePermission(
                domain: 'example.com',
                type: SitePermissionType.camera,
                state: PermissionState.allow,
              ),
              onChanged: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Camera'), findsOneWidget);
    });

    testWidgets('current status visible', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SitePermissionTile(
              permission: const SitePermission(
                domain: 'example.com',
                type: SitePermissionType.microphone,
                state: PermissionState.deny,
              ),
              onChanged: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Deny'), findsOneWidget);
    });

    testWidgets('selector interaction opens popup menu', (tester) async {
      PermissionState? changedTo;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SitePermissionTile(
              permission: const SitePermission(
                domain: 'example.com',
                type: SitePermissionType.location,
                state: PermissionState.ask,
              ),
              onChanged: (state) => changedTo = state,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the popup menu button
      await tester.tap(find.byType(PopupMenuButton<PermissionState>));
      await tester.pumpAndSettle();

      // Menu items should be visible ("Ask every time" also appears
      // in the ListTile subtitle, so we expect at least 1 in the popup)
      expect(find.text('Ask every time'), findsWidgets);
      expect(find.text('Allow'), findsOneWidget);
      expect(find.text('Deny'), findsOneWidget);

      // Tap "Allow"
      await tester.tap(find.text('Allow'));
      await tester.pumpAndSettle();

      expect(changedTo, PermissionState.allow);
    });

    testWidgets('shows correct icon for each permission type', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                SitePermissionTile(
                  permission: const SitePermission(
                    domain: 'a.com',
                    type: SitePermissionType.camera,
                    state: PermissionState.ask,
                  ),
                  onChanged: (_) {},
                ),
                SitePermissionTile(
                  permission: const SitePermission(
                    domain: 'a.com',
                    type: SitePermissionType.microphone,
                    state: PermissionState.ask,
                  ),
                  onChanged: (_) {},
                ),
                SitePermissionTile(
                  permission: const SitePermission(
                    domain: 'a.com',
                    type: SitePermissionType.location,
                    state: PermissionState.ask,
                  ),
                  onChanged: (_) {},
                ),
                SitePermissionTile(
                  permission: const SitePermission(
                    domain: 'a.com',
                    type: SitePermissionType.notifications,
                    state: PermissionState.ask,
                  ),
                  onChanged: (_) {},
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.videocam), findsOneWidget);
      expect(find.byIcon(Icons.mic), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsOneWidget);
      expect(find.byIcon(Icons.notifications), findsOneWidget);
    });
  });
}
