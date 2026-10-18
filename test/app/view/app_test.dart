import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/features/home/cubit/home_cubit.dart';
import 'package:golden_moments/features/home/cubit/home_state.dart';
import 'package:golden_moments/features/home/presentation/screens/home_page.dart';

class _LoadedHome extends HomeCubit {
  new() {
    emit(const HomeState(status: HomeStatus.loaded, preferencesReady: true));
  }
}

void main() {
  testWidgets('home renders the game catalog sections', (tester) async {
    final cubit = _LoadedHome();
    addTearDown(cubit.close);
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<HomeCubit>.value(
          value: cubit,
          child: const HomeView(),
        ),
      ),
    );
    expect(find.text('Golden Moments'), findsOneWidget);
    expect(find.text('Suggested packs'), findsOneWidget);
    expect(find.text('Library'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
