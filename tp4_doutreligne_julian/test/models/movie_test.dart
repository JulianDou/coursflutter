import 'package:flutter_test/flutter_test.dart';
import 'package:can_i_watch/models/movie.dart';

void main() {
  group('MovieListItem Tests', () {
    test('Parse correctement un JSON valide', () {
      // Arrange : Préparer des données JSON
      final json = {
        'id': 123,
        'title': 'Test Movie',
        'year': 2024,
      };

      // Act : Créer un MovieListItem à partir du JSON
      final movie = MovieListItem.fromJson(json);

      // Assert : Vérifier que les valeurs sont correctes
      expect(movie.id, 123);
      expect(movie.title, 'Test Movie');
      expect(movie.year, 2024);
    });

    test('Gère les valeurs nulles avec des valeurs par défaut', () {
      // JSON avec des champs manquants
      final json = {
        'id': 456,
      };

      final movie = MovieListItem.fromJson(json);

      // Vérifie que les valeurs par défaut sont appliquées
      expect(movie.id, 456);
      expect(movie.title, 'Sans titre');
      expect(movie.year, 0);
    });

    // ... et bien plus ! Crée d'autres tests pertinents :
    // - Teste d'autres cas limites
    // - Teste le parsing du modèle Movie complet
    // - Teste le getter posterUrl avec et sans poster
  });
}
