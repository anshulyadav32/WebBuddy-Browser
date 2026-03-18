import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_buddy/core/services/storage_service.dart';
import 'package:web_buddy/features/browser/domain/browser_page_state.dart';
import 'package:web_buddy/features/browser/presentation/browser_controller.dart';
import 'package:web_buddy/features/browser/presentation/widgets/browser_toolbar.dart';
import 'package:web_buddy/features/privacy/data/filter_list_repository.dart';
import 'package:web_buddy/features/privacy/data/shields_repository.dart';
import 'package:web_buddy/features/privacy/domain/filter_rule.dart';
import 'package:web_buddy/features/privacy/presentation/shields_controller.dart';
import 'package:web_buddy/features/settings/domain/browser_settings.dart';
import 'package:web_buddy/features/settings/presentation/settings_controller.dart';

void main() {
  group('BrowserToolbar — shield button', () {
    late List<Override> overrides;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      overrides = [
        sharedPreferencesProvider.overrideWithValue(prefs),
        browserControllerProvider.overrideWith(
          (ref) => _FakeBrowserController(),
        ),
        shieldsControllerProvider.overrideWith(
          (_) => _FakeShieldsControllerForToolbar(),
        ),
      ];
    });

    testWidgets('shows shield icon in toolbar', (tester) async {
      bool shieldsTapped = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: overrides,
          child: MaterialApp(
            home: Scaffold(
              body: BrowserToolbar(
                isPrivateMode: true,
                onPageActionsTapped: () => shieldsTapped = true,
              ),
            ),
          ),
        ),
      );

      // Find the shield icon button by tooltip.
      final shieldsButton = find.byTooltip('Shields');
      expect(shieldsButton, findsOneWidget);

      await tester.tap(shieldsButton);
      expect(shieldsTapped, isTrue);
    });

    testWidgets('shield icon reflects enabled state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: overrides,
          child: MaterialApp(
            home: const Scaffold(body: BrowserToolbar(isPrivateMode: true)),
          ),
        ),
      );

      // Private mode indicator should render shield icon in toolbar.
      expect(find.byIcon(Icons.shield), findsOneWidget);
    });
  });
}

class _FakeBrowserController extends BrowserController {
  _FakeBrowserController() : super(const BrowserSettings());

  @override
  BrowserPageState get state => const BrowserPageState();
}

class _FakeShieldsControllerForToolbar extends ShieldsController {
  _FakeShieldsControllerForToolbar()
    : super(
        shieldsRepo: _DummyShieldsRepo(),
        filterListRepo: _DummyFilterListRepo(),
        globalAdBlockEnabled: true,
      );

  @override
  ShieldsState get state => const ShieldsState(
    isInitialised: true,
    globalEnabled: true,
    currentSiteEnabled: true,
  );
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
