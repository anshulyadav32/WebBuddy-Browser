import 'package:flutter_test/flutter_test.dart';
import 'package:web_buddy/features/settings/domain/site_permission.dart';
import 'package:web_buddy/features/settings/domain/site_settings.dart';

void main() {
  group('SitePermission', () {
    test('defaults to ask state', () {
      const p = SitePermission(
        domain: 'x.com',
        type: SitePermissionType.camera,
      );
      expect(p.state, PermissionState.ask);
    });

    test('copyWith updates state', () {
      const p = SitePermission(
        domain: 'x.com',
        type: SitePermissionType.microphone,
      );
      final updated = p.copyWith(state: PermissionState.deny);
      expect(updated.state, PermissionState.deny);
      expect(updated.domain, 'x.com');
    });

    test('equality by domain + type only', () {
      const a = SitePermission(
        domain: 'x.com',
        type: SitePermissionType.camera,
        state: PermissionState.allow,
      );
      const b = SitePermission(
        domain: 'x.com',
        type: SitePermissionType.camera,
        state: PermissionState.deny,
      );
      // Same domain + type → equal, even if state differs
      expect(a, equals(b));
    });

    test('different type means not equal', () {
      const a = SitePermission(
        domain: 'x.com',
        type: SitePermissionType.camera,
      );
      const b = SitePermission(
        domain: 'x.com',
        type: SitePermissionType.location,
      );
      expect(a, isNot(equals(b)));
    });

    test('round-trips through toMap/fromMap', () {
      const p = SitePermission(
        domain: 'test.org',
        type: SitePermissionType.notifications,
        state: PermissionState.allow,
      );
      final restored = SitePermission.fromMap(p.toMap());
      expect(restored.domain, 'test.org');
      expect(restored.type, SitePermissionType.notifications);
      expect(restored.state, PermissionState.allow);
    });
  });

  group('SiteSettings', () {
    test('defaults have null overrides and empty permissions', () {
      const s = SiteSettings(domain: 'example.com');
      expect(s.javaScriptEnabled, isNull);
      expect(s.popUpBlockingEnabled, isNull);
      expect(s.permissions, isEmpty);
    });

    test('copyWith sets nullable field to null', () {
      const s = SiteSettings(domain: 'a.com', javaScriptEnabled: false);
      final updated = s.copyWith(javaScriptEnabled: () => null);
      expect(updated.javaScriptEnabled, isNull);
    });

    test('copyWith updates permissions', () {
      const s = SiteSettings(domain: 'a.com');
      final updated = s.copyWith(
        permissions: [
          const SitePermission(
            domain: 'a.com',
            type: SitePermissionType.camera,
            state: PermissionState.allow,
          ),
        ],
      );
      expect(updated.permissions.length, 1);
    });

    test('equality by domain only', () {
      const a = SiteSettings(domain: 'x.com', javaScriptEnabled: true);
      const b = SiteSettings(domain: 'x.com', javaScriptEnabled: false);
      expect(a, equals(b));
    });

    test('different domains not equal', () {
      const a = SiteSettings(domain: 'x.com');
      const b = SiteSettings(domain: 'y.com');
      expect(a, isNot(equals(b)));
    });

    test('round-trips through toMap/fromMap', () {
      const s = SiteSettings(
        domain: 'test.com',
        javaScriptEnabled: false,
        popUpBlockingEnabled: true,
        permissions: [
          SitePermission(
            domain: 'test.com',
            type: SitePermissionType.location,
            state: PermissionState.deny,
          ),
        ],
      );
      final restored = SiteSettings.fromMap(s.toMap());
      expect(restored.domain, 'test.com');
      expect(restored.javaScriptEnabled, false);
      expect(restored.popUpBlockingEnabled, true);
      expect(restored.permissions.length, 1);
      expect(restored.permissions.first.type, SitePermissionType.location);
      expect(restored.permissions.first.state, PermissionState.deny);
    });

    test('fromMap handles missing permissions', () {
      final s = SiteSettings.fromMap({'domain': 'bare.com'});
      expect(s.domain, 'bare.com');
      expect(s.permissions, isEmpty);
    });
  });
}
