import 'package:dio/dio.dart';
import '../models/movie.dart';
import '../models/streaming_service.dart';

class MovieService {
  final Dio _dio = Dio();
  static const String _baseUrl = 'https://api.watchmode.com/v1';

  // Récupère la clé API depuis les variables d'environnement
  static const String _apiKey = String.fromEnvironment(
    'WATCHMODE_API_KEY',
    defaultValue: '', // Valeur par défaut si la clé n'est pas fournie
  );

  /// Fetch all available streaming services
  Future<List<StreamingService>> getStreamingServices() async {
    if (_apiKey.isEmpty) {
      throw Exception(
        'Clé API manquante ! Lance l\'app avec --dart-define=WATCHMODE_API_KEY=ta_clé'
      );
    }

    try {
      final response = await _dio.get(
        '$_baseUrl/sources/',
        queryParameters: {
          'apiKey': _apiKey,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> sources = response.data;
        return sources.map((json) => StreamingService.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors du chargement des services');
      }
    } catch (e) {
      throw Exception('Erreur réseau : $e');
    }
  }

  Future<List<MovieListItem>> getMovies({int limit = 20, List<int> sourceIds = const []}) async {
    // Vérifie que la clé API est bien fournie
    if (_apiKey.isEmpty) {
      throw Exception(
        'Clé API manquante ! Lance l\'app avec --dart-define=WATCHMODE_API_KEY=ta_clé'
      );
    }

    try {
      final params = {
        'apiKey': _apiKey,
        'types': 'movie',
        'limit': limit,
      };

      if (sourceIds.isNotEmpty) {
        params['source_ids'] = sourceIds.join(',');
      }

      final response = await _dio.get(
        '$_baseUrl/list-titles/',
        queryParameters: params,
      );

      if (response.statusCode == 200) {
        final List<dynamic> titles = response.data['titles'];
        return titles.map((json) => MovieListItem.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors du chargement des films');
      }
    } catch (e) {
      throw Exception('Erreur réseau : $e');
    }
  }

  Future<Movie> getMovieDetails(int movieId) async {
    if (_apiKey.isEmpty) {
      throw Exception(
        'Clé API manquante ! Lance l\'app avec --dart-define=WATCHMODE_API_KEY=ta_clé'
      );
    }

    try {
      final response = await _dio.get(
        '$_baseUrl/title/$movieId/details/',
        queryParameters: {
          'apiKey': _apiKey,
        },
      );

      if (response.statusCode == 200) {
        return Movie.fromJson(response.data);
      } else {
        throw Exception('Erreur lors du chargement des détails');
      }
    } catch (e) {
      throw Exception('Erreur réseau : $e');
    }
  }

  /// Search movies by title
  Future<List<MovieListItem>> searchMovies(String query, {int limit = 20, List<int> sourceIds = const []}) async {
    if (_apiKey.isEmpty) {
      throw Exception(
        'Clé API manquante ! Lance l\'app avec --dart-define=WATCHMODE_API_KEY=ta_clé'
      );
    }

    if (query.isEmpty) {
      return [];
    }

    try {
      final params = {
        'apiKey': _apiKey,
        'search_field': 'name',
        'search_value': query,
        'search_type': 1, // title autocomplete
        'types': 'movie',
        'limit': limit,
      };

      if (sourceIds.isNotEmpty) {
        params['source_ids'] = sourceIds.join(',');
      }

      final response = await _dio.get(
        '$_baseUrl/autocomplete-search/',
        queryParameters: params,
      );

      if (response.statusCode == 200) {
        final List<dynamic> results = response.data['results'] ?? [];
        final filtered = results.where((json) {
          final resultType = json['result_type'];
          final type = json['type'];
          return resultType == 'title' && type == 'movie';
        });

        return filtered
            .map((json) => MovieListItem(
                  id: json['id'],
                  title: json['title'] ?? json['name'] ?? 'Sans titre',
                  year: json['year'] ?? 0,
                ))
            .toList();
      } else {
        throw Exception('Erreur lors de la recherche');
      }
    } catch (e) {
      throw Exception('Erreur réseau : $e');
    }
  }
}
