import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_buddy/core/services/storage_service.dart';
import 'package:web_buddy/features/settings/data/site_settings_repository.dart';
import 'package:web_buddy/features/settings/domain/site_permission.dart';
import 'package:web_buddy/features/settings/presentation/site_settings_controller.dart';

void main() {
  group('SiteSettingsController', () {
    late SiteSettingsRepository repo;
    late SiteSettingsController controller;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      repo = SiteSettingsRepository(StorageService(prefs));
      controller = SiteSettingsController(repo);
    });

    test('initial state is empty', () {
      expect(controller.state, isEmpty);
    });

    test('forDomain returns default when not stored', () {
      final s = controller.forDomain('unknown.com');
      expect(s.domain, 'unknown.com');
      expect(s.javaScriptEnabled, isNull);
    });

    test('setJavaScript updates state and persists', () async {
      await controller.setJavaScript('example.com', false);

      expect(controller.state['example.com']!.javaScriptEnabled, false);
      expect(repo.loadForDomain('example.com')!.javaScriptEnabled, false);
    });

    test('setPopUpBlocking updates state and persists', () async {
      await controller.setPopUpBlocking('example.com', false);

      expect(controller.state['example.com']!.popUpBlockingEnabled, false);
    });

    test('setPermission adds new permission', () async {
      await controller.setPermission(
        'test.com',
        SitePermissionType.camera,
        PermissionState.allow,
      );

      final perms = controller.state['test.com']!.permissions;
      expect(perms.length, 1);
      expect(perms.first.type, SitePermissionType.camera);
      expect(perms.first.state, PermissionState.allow);
    });

    test('setPermission updates existing permission', () async {
      await controller.setPermission(
        'test.com',
        SitePermissionType.camera,
        PermissionState.allow,
      );
      await controller.setPermission(
        'test.com',
        SitePermissionType.camera,
        PermissionState.deny,
      );

      final perms = controller.state['test.com']!.permissions;
      expect(perms.length, 1);
      expect(perms.first.state, PermissionState.deny);
    });

    test('removeDomain clears site from state', () async {
      await controller.setJavaScript('x.com', false);
      await controller.removeDomain('x.com');

      expect(controller.state.containsKey('x.com'), false);
    });

    test('clearAll empties state and repo', () async {
      await controller.setJavaScript('a.com', true);
      await controller.setJavaScript('b.com', false);

      await controller.clearAll();

      expect(controller.state, isEmpty);
      expect(repo.loadAll(), isEmpty);
    });
  });
}
