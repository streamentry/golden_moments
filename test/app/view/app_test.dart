import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/features/home/cubit/home_cubit.dart';
import 'package:golden_moments/features/home/cubit/home_state.dart';
import 'package:golden_moments/features/home/presentation/screens/home_page.dart';

class _LoadedHome extends HomeCubit {
  _LoadedHome() {
    emit(const HomeState(status: HomeStatus.loaded));
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
    expect(find.text('Daily Packs'), findsOneWidget);
    expect(find.text('Library'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
