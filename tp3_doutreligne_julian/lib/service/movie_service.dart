import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class Movie {
  // TODO: Déclare les 4 propriétés finales :
  // - title (String)
  // - year (int)
  // - poster (String)
  // - description (String)
  final String title;
  final int year;
  final String poster;
  final String description;

  // TODO: Crée le constructeur avec des paramètres nommés required
  Movie({
    required this.title,
    required this.year,
    required this.poster,
    required this.description,
  });

  // TODO: Crée un factory constructor Movie.fromJson(Map<String, dynamic> json)
  // qui retourne une instance de Movie en lisant les valeurs du json
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['title'],
      year: json['year'],
      poster: json['poster'],
      description: json['description'],
    );
  }
}

class MovieService {
  Future<List<Movie>> loadLocalMovies() async {
    final data = await rootBundle.loadString('assets/data/movies.json');
    final List<dynamic> jsonList = json.decode(data);
    return jsonList.map((json) => Movie.fromJson(json)).toList();
  }
}
