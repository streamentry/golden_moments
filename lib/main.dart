import 'dart:async';

import 'package:golden_moments/app/app.dart';
import 'package:golden_moments/bootstrap.dart';

void main() {
  unawaited(bootstrap(() => const App()));
}
