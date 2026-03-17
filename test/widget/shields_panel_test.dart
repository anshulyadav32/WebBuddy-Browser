import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_buddy/core/services/storage_service.dart';
import 'package:web_buddy/features/privacy/data/filter_list_repository.dart';
import 'package:web_buddy/features/privacy/data/shields_repository.dart';
import 'package:web_buddy/features/privacy/domain/blocked_request.dart';
import 'package:web_buddy/features/privacy/domain/filter_rule.dart';
import 'package:web_buddy/features/privacy/domain/shield_stats.dart';
import 'package:web_buddy/features/privacy/presentation/shields_controller.dart';
import 'package:web_buddy/features/privacy/presentation/widgets/shields_panel.dart';

void main() {
  group('ShieldsPanel', () {
    testWidgets('shows shields up message when enabled', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            shieldsControllerProvider.overrideWith(
              (_) => _FakeShieldsController(
                const ShieldsState(
                  isInitialised: true,
                  globalEnabled: true,
                  currentDomain: 'example.com',
                  currentSiteEnabled: true,
                  stats: ShieldStats(
                    adsBlocked: 3,
                    trackersBlocked: 2,
                    totalBlocked: 5,
                  ),
                ),
              ),
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: ShieldsPanel())),
        ),
      );

      expect(find.text('Shields'), findsOneWidget);
      expect(find.text('example.com'), findsOneWidget);
      expect(
        find.text('Shields are up \u2014 protecting this site.'),
        findsOneWidget,
      );
      expect(find.text('3'), findsOneWidget); // ads
      expect(find.text('2'), findsOneWidget); // trackers
      expect(find.text('5'), findsOneWidget); // total
    });

    testWidgets('shows shields down message when site disabled', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            shieldsControllerProvider.overrideWith(
              (_) => _FakeShieldsController(
                const ShieldsState(
                  isInitialised: true,
                  globalEnabled: true,
                  currentDomain: 'example.com',
                  currentSiteEnabled: false,
                ),
              ),
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: ShieldsPanel())),
        ),
      );

      expect(find.text('Shields are down for this site.'), findsOneWidget);
    });

    testWidgets('shows global disabled message', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            shieldsControllerProvider.overrideWith(
              (_) => _FakeShieldsController(
                const ShieldsState(
                  isInitialised: true,
                  globalEnabled: false,
                  currentDomain: 'example.com',
                  currentSiteEnabled: true,
                ),
              ),
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: ShieldsPanel())),
        ),
      );

      expect(
        find.text('Shields are disabled globally in Settings.'),
        findsOneWidget,
      );
    });

    testWidgets('shows blocked requests log', (tester) async {
      final blockedRequests = [
        BlockedRequest(
          url: 'https://ad.doubleclick.net/ad.js',
          domain: 'ad.doubleclick.net',
          matchedFilter: '||doubleclick.net^',
          blockedAt: DateTime(2025, 6, 15, 10, 30, 0),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            shieldsControllerProvider.overrideWith(
              (_) => _FakeShieldsController(
                ShieldsState(
                  isInitialised: true,
                  globalEnabled: true,
                  currentDomain: 'example.com',
                  currentSiteEnabled: true,
                  stats: const ShieldStats(totalBlocked: 1, adsBlocked: 1),
                  blockedRequests: blockedRequests,
                ),
              ),
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: ShieldsPanel())),
        ),
      );

      expect(find.text('Blocked requests'), findsOneWidget);
      expect(find.text('ad.doubleclick.net'), findsOneWidget);
    });

    testWidgets('shows platform caveat text', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            shieldsControllerProvider.overrideWith(
              (_) => _FakeShieldsController(
                const ShieldsState(
                  isInitialised: true,
                  globalEnabled: true,
                  currentDomain: 'example.com',
                  currentSiteEnabled: true,
                ),
              ),
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: ShieldsPanel())),
        ),
      );

      expect(find.textContaining('navigation-level requests'), findsOneWidget);
    });

    testWidgets('shows switch toggle', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            shieldsControllerProvider.overrideWith(
              (_) => _FakeShieldsController(
                const ShieldsState(
                  isInitialised: true,
                  globalEnabled: true,
                  currentDomain: 'example.com',
                  currentSiteEnabled: true,
                ),
              ),
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: ShieldsPanel())),
        ),
      );

      expect(find.byType(Switch), findsOneWidget);
    });
  });
}

/// A simple fake [ShieldsController] that returns fixed state.
class _FakeShieldsController extends ShieldsController {
  _FakeShieldsController(this._fakeState)
    : super(
        shieldsRepo: _DummyShieldsRepo(),
        filterListRepo: _DummyFilterListRepo(),
        globalAdBlockEnabled: _fakeState.globalEnabled,
      );

  final ShieldsState _fakeState;

  @override
  ShieldsState get state => _fakeState;
}

class _DummyShieldsRepo extends ShieldsRepository {
  _DummyShieldsRepo() : super(_DummyStorage());
}

class _DummyFilterListRepo extends FilterListRepository {
  @override
  Future<List<FilterRule>> loadRules() async => [];
}

class _DummyStorage extends StorageService {
  _DummyStorage() : super(_FakePrefs());
}

// Minimal fake SharedPreferences for the dummy storage.
class _FakePrefs implements SharedPreferences {
  final _map = <String, Object>{};

  @override
  String? getString(String key) => _map[key] as String?;
  @override
  Future<bool> setString(String key, String value) async {
    _map[key] = value;
    return true;
  }

  @override
  int? getInt(String key) => _map[key] as int?;
  @override
  Future<bool> setInt(String key, int value) async {
    _map[key] = value;
    return true;
  }

  @override
  bool? getBool(String key) => _map[key] as bool?;
  @override
  Future<bool> setBool(String key, bool value) async {
    _map[key] = value;
    return true;
  }

  @override
  Future<bool> remove(String key) async {
    _map.remove(key);
    return true;
  }

  @override
  Future<bool> clear() async {
    _map.clear();
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
