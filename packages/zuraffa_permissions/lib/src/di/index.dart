// GENERATED - DO NOT EDIT
import 'package:zuraffa/zuraffa.dart';

import 'datasources/index.dart';
import 'repositories/permission_repositories_di.dart';
import 'usecases/index.dart';

export 'datasources/index.dart';
export 'repositories/permission_repositories_di.dart';
export 'usecases/index.dart';

void setupDependencies(GetIt getIt) {
  registerAllDataSources(getIt);
  registerPermissionRepositories(getIt);
  registerAllUseCases(getIt);
}

// END GENERATED
