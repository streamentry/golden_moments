import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/app/cubit/navigation_cubit.dart';

void main() {
  late NavigationCubit cubit;
  setUp(() => cubit = NavigationCubit());
  tearDown(() => cubit.close());
  test('downloads deep link targets the existing second tab', () {
    cubit.handleDeepLink('/downloads');
    expect(cubit.state.currentIndex, 1);
    expect(cubit.isDownloadsTab, isTrue);
    expect(cubit.currentTabName, 'Downloads');
  });
  test('invalid tabs are rejected', () {
    for (final index in [-1, 2, 3, 99]) {
      cubit.setIndex(index);
    }
    expect(cubit.state.currentIndex, 0);
  });
  test('back returns home before allowing exit', () {
    cubit.goToDownloads();
    expect(cubit.handleBackPress(), isFalse);
    expect(cubit.state.currentIndex, 0);
    expect(cubit.handleBackPress(), isTrue);
    cubit.handleDeepLink('/unknown');
    expect(cubit.state.currentIndex, 0);
  });
}
