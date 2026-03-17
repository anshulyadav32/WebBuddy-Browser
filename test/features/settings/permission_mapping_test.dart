import 'package:flutter_test/flutter_test.dart';
import 'package:web_buddy/features/settings/domain/site_permission.dart';

/// Tests for permission enum mappings and origin extraction.
void main() {
  group('SitePermissionType — UI label mapping', () {
    test('camera maps to Camera label', () {
      expect(SitePermissionType.camera.label, 'Camera');
    });

    test('microphone maps to Microphone label', () {
      expect(SitePermissionType.microphone.label, 'Microphone');
    });

    test('location maps to Location label', () {
      expect(SitePermissionType.location.label, 'Location');
    });

    test('notifications maps to Notifications label', () {
      expect(SitePermissionType.notifications.label, 'Notifications');
    });

    test('all permission types have non-empty labels', () {
      for (final type in SitePermissionType.values) {
        expect(type.label, isNotEmpty);
      }
    });
  });

  group('PermissionState — UI label mapping', () {
    test('ask maps to Ask label', () {
      expect(PermissionState.ask.label, 'Ask every time');
    });

    test('allow maps to Allow label', () {
      expect(PermissionState.allow.label, 'Allow');
    });

    test('deny maps to Deny label', () {
      expect(PermissionState.deny.label, 'Deny');
    });

    test('all states have non-empty labels', () {
      for (final state in PermissionState.values) {
        expect(state.label, isNotEmpty);
      }
    });
  });

  group('SitePermission — serialization', () {
    test('toMap/fromMap round-trip', () {
      const perm = SitePermission(
        domain: 'example.com',
        type: SitePermissionType.camera,
        state: PermissionState.allow,
      );

      final map = perm.toMap();
      final restored = SitePermission.fromMap(map);

      expect(restored.domain, perm.domain);
      expect(restored.type, perm.type);
      expect(restored.state, perm.state);
    });

    test('copyWith updates state', () {
      const perm = SitePermission(
        domain: 'example.com',
        type: SitePermissionType.microphone,
        state: PermissionState.ask,
      );

      final updated = perm.copyWith(state: PermissionState.deny);
      expect(updated.state, PermissionState.deny);
      expect(updated.domain, 'example.com');
      expect(updated.type, SitePermissionType.microphone);
    });

    test('equality based on domain and type', () {
      const a = SitePermission(
        domain: 'a.com',
        type: SitePermissionType.camera,
        state: PermissionState.allow,
      );
      const b = SitePermission(
        domain: 'a.com',
        type: SitePermissionType.camera,
        state: PermissionState.deny,
      );
      // Equality is based on domain + type, not state
      expect(a, equals(b));
    });

    test('different types are not equal', () {
      const a = SitePermission(
        domain: 'a.com',
        type: SitePermissionType.camera,
      );
      const b = SitePermission(
        domain: 'a.com',
        type: SitePermissionType.microphone,
      );
      expect(a, isNot(equals(b)));
    });
  });

  group('Origin extraction', () {
    test('domain string used directly as origin', () {
      const perm = SitePermission(
        domain: 'example.com',
        type: SitePermissionType.location,
      );
      expect(perm.domain, 'example.com');
    });

    test('serialized domain preserved', () {
      const perm = SitePermission(
        domain: 'sub.example.co.uk',
        type: SitePermissionType.camera,
      );
      final map = perm.toMap();
      expect(map['domain'], 'sub.example.co.uk');
    });
  });
}
