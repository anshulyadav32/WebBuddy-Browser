import 'package:flutter_test/flutter_test.dart';
import 'package:web_buddy/features/tabs/domain/models/browser_tab_state.dart';
import 'package:web_buddy/features/tabs/domain/models/tabs_state.dart';

void main() {
  test('activeTab getter returns correct tab', () {
    const tab1 = BrowserTabState(id: '1');
    const tab2 = BrowserTabState(id: '2');

    final state = TabsState(
      tabs: [tab1, tab2],
      activeTabId: '2',
    );

    expect(state.activeTab.id, '2');
  });
}
