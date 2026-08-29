import 'package:flutter_test/flutter_test.dart';
import 'package:zuraffa/zuraffa.dart' show GetIt;
import 'package:zuraffa_permissions/zuraffa_permissions.dart';

import 'package:example/main.dart';

void main() {
  testWidgets('permission app renders and wires the service', (tester) async {
    registerPermissionDependencies(GetIt.instance);
    await tester.pumpWidget(const PermissionApp());
    await tester.pumpAndSettle();

    // The app bar title and all eleven built-in scopes should render.
    expect(find.text('zuraffa_permissions'), findsOneWidget);
    final service = GetIt.instance<PermissionService>();
    expect(service.scopes, hasLength(11));
  });
}
