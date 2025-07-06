import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flixvod/modules/catalogue/widgets/media_card.dart';
import 'package:flixvod/modules/catalogue/bloc/catalogue_bloc.dart';
import 'package:flixvod/modules/catalogue/bloc/catalogue_state.dart';
import 'package:flixvod/models/media.dart';
import '../../../services/storage/firebase_service_test_helper.dart';

class MockCatalogueBloc extends CatalogueBloc {
  @override
  Stream<CatalogueState> get stream => Stream.value(const CatalogueState());

  @override
  CatalogueState get state => const CatalogueState();
}

void main() {
  group('MediaCard', () {
    late MockCatalogueBloc mockCatalogueBloc;

    setUp(() {
      mockCatalogueBloc = MockCatalogueBloc();
    });

    Widget createTestWidget(Media media, {VoidCallback? onDeleted}) {
      return MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'US'),
        ],
        home: BlocProvider<CatalogueBloc>(
          create: (context) => mockCatalogueBloc,
          child: Scaffold(
            body: MediaCard(
              media: media,
              onDeleted: onDeleted,
            ),
          ),
        ),
      );
    }

    testWidgets('should display media title and description', (tester) async {
      final testMedia = FirebaseServiceTestHelper.createTestMovie(
        title: 'Test Movie',
        description: 'Test Description',
      );

      await tester.pumpWidget(createTestWidget(testMedia));

      expect(find.text('Test Movie'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);
    });

    testWidgets('should display correct media type icon for movie', (tester) async {
      final testMovie = FirebaseServiceTestHelper.createTestMovie();

      await tester.pumpWidget(createTestWidget(testMovie));

      // Movie should show play arrow icon
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('should display correct media type icon for series', (tester) async {
      final testSeries = FirebaseServiceTestHelper.createTestSeries();

      await tester.pumpWidget(createTestWidget(testSeries));

      // Series should NOT show play arrow icon (only movies have play buttons)
      expect(find.byIcon(Icons.play_arrow), findsNothing);
    });

    testWidgets('should display rating', (tester) async {
      final testMedia = FirebaseServiceTestHelper.createTestMovie(rating: 4.0);

      await tester.pumpWidget(createTestWidget(testMedia));

      expect(find.text('4.0'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('should display episode count for series', (tester) async {
      final testSeries = FirebaseServiceTestHelper.createTestSeries(episodeCount: 3);

      await tester.pumpWidget(createTestWidget(testSeries));

      expect(find.textContaining('3 episodes'), findsOneWidget);
    });

    testWidgets('should show delete confirmation dialog when long pressed', (tester) async {
      final testMedia = FirebaseServiceTestHelper.createTestMovie(title: 'Test Movie');

      await tester.pumpWidget(createTestWidget(
        testMedia,
        onDeleted: () {},
      ));

      //Trigger delete dialog
      await tester.longPress(find.byType(MediaCard));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('should close dialog when cancel is tapped', (tester) async {
      final testMedia = FirebaseServiceTestHelper.createTestMovie();

      await tester.pumpWidget(createTestWidget(
        testMedia,
        onDeleted: () {},
      ));

      // Long press to trigger delete dialog
      await tester.longPress(find.byType(MediaCard));
      await tester.pumpAndSettle();

      // Tap cancel
      final cancelButton = find.byType(TextButton).first;
      await tester.tap(cancelButton);
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('should display image when imageUrl is provided', (tester) async {
      final testMedia = FirebaseServiceTestHelper.createTestMovie();

      await tester.pumpWidget(createTestWidget(testMedia));
      expect(find.byType(Container), findsWidgets);
      expect(find.byType(MediaCard), findsOneWidget);
    });

    testWidgets('should handle missing image', (tester) async {
      const testMedia = Media(
        id: 'test-id',
        title: 'Test Movie',
        description: 'Test Description',
        imageUrl: '',
        videoUrl: 'https://example.com/video.mp4',
        type: MediaType.movie,
        year: 2025,
        rating: 4.0,
        genres: ['Action'],
        duration: 120,
        episodes: const [],
      );

      await tester.pumpWidget(createTestWidget(testMedia));
      expect(find.text('Test Movie'), findsOneWidget);
    });
  });
}
