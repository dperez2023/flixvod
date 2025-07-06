import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flixvod/modules/catalogue/pages/catalogue_page.dart';
import 'package:flixvod/modules/catalogue/bloc/catalogue_bloc.dart';
import 'package:flixvod/modules/catalogue/bloc/catalogue_state.dart';
import 'package:flixvod/modules/catalogue/bloc/catalogue_event.dart';
import 'package:flixvod/models/media.dart';

class MockCatalogueBloc extends Fake implements CatalogueBloc {
  @override
  CatalogueState get state => const CatalogueState();
  
  @override
  Stream<CatalogueState> get stream => Stream.value(const CatalogueState());
  
  @override
  Future<void> close() async {}
  
  @override
  void add(CatalogueEvent event) {
    // Mock implementation - just accept events without doing anything
  }
}

void main() {
  group('CataloguePage', () {
    late MockCatalogueBloc mockCatalogueBloc;

    setUp(() {
      mockCatalogueBloc = MockCatalogueBloc();
    });

    Widget createTestWidget({
      List<Media> movies = const [],
      List<Media> series = const [],
      bool isLoading = false,
    }) {
      return MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
        home: BlocProvider<CatalogueBloc>(
          create: (context) => mockCatalogueBloc,
          child: const CataloguePage(),
        ),
      );
    }

    testWidgets('should render app bar with title', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('FlixVOD'), findsOneWidget);
    });

    testWidgets('should render catalogue page widget', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Should have the basic page structure
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(CataloguePage), findsOneWidget);
    });
  });
}
