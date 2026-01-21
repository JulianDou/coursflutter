import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:can_i_watch/models/movie.dart';
import 'package:can_i_watch/models/streaming_service.dart';
import 'package:can_i_watch/pages/movie_list_page.dart';
import 'package:can_i_watch/services/movie_service.dart';

void main() {
  group('MovieListCard Widget Tests', () {
    testWidgets("Affiche correctement le titre et l'année d'un film",
        (WidgetTester tester) async {
      // Créer un film de test
      final testMovie = MovieListItem(
        id: 1,
        title: 'Test Movie',
        year: 2024,
      );

      // Construire le widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MovieListCard(
              movieService: MockMovieService(),
              movie: testMovie,
              isFavorite: false,
              onFavoriteTap: () {},
            ),
          ),
        ),
      );

      // Assert : Vérifier que le titre et l'année sont affichés
      expect(find.text('Test Movie'), findsOneWidget);
      expect(find.text('Year: 2024'), findsOneWidget);
    });

    testWidgets("Affiche l'icône favorite quand le film est favori",
        (WidgetTester tester) async {
      final testMovie = MovieListItem(
        id: 1,
        title: 'Favorite Movie',
        year: 2024,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MovieListCard(
              movieService: MockMovieService(),
              movie: testMovie,
              isFavorite: true,
              onFavoriteTap: () {},
            ),
          ),
        ),
      );

      // Vérifier que l'icône favorite pleine est affichée
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    // ... et bien plus ! Crée d'autres tests de widgets :
    // - Teste l'icône favorite_border quand isFavorite est false
    // - Teste l'affichage du CircleAvatar avec la première lettre
    // - Teste la couleur du CircleAvatar selon la première lettre
  });
}

// Mock (simulation) du MovieService pour les tests
// Permet de créer un MovieListCard sans avoir besoin d'une vraie connexion API
// Dans ces tests, on ne teste que l'affichage, donc ces méthodes ne sont jamais appelées
class MockMovieService implements MovieService {
  @override
  Future<List<MovieListItem>> getMovies({int limit = 20, List<int> sourceIds = const []}) async {
    return []; // Retourne une liste vide (non utilisée dans ces tests)
  }

  @override
  Future<Movie> getMovieDetails(int movieId) async {
    // Lance une erreur car non implémenté (non utilisé dans ces tests)
    throw UnimplementedError();
  }

  @override
  Future<List<StreamingService>> getStreamingServices() async {
    throw UnimplementedError();
  }

  @override
  Future<List<MovieListItem>> searchMovies(String query, {int limit = 20, List<int> sourceIds = const []}) async {
    throw UnimplementedError();
  }
}
