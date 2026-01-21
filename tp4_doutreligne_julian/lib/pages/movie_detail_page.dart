import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/movie.dart';
import '../services/movie_service.dart';

class MovieDetailPage extends StatefulWidget {
  final MovieService movieService;
  final int movieId;

  const MovieDetailPage({
    super.key,
    required this.movieService,
    required this.movieId,
  });

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  Movie? movie;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMovieDetails();
  }

  Future<void> _loadMovieDetails() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final loadedMovie = await widget.movieService.getMovieDetails(
        widget.movieId,
      );
      setState(() {
        movie = loadedMovie;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _openTrailer() async {
    if (movie?.trailer == null) return;

    final uri = Uri.parse(movie!.trailer!);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open trailer'),
          backgroundColor: Color(0xFFD32F2F),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(movie?.title ?? 'Loading...')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 60, color: Color(0xFFD32F2F)),
                      const SizedBox(height: 16),
                      Text(errorMessage!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadMovieDetails,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Poster image
                      Image.network(
                        movie!.posterUrl,
                        width: double.infinity,
                        height: 500,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 500,
                          color: const Color(0xFF23262C),
                          child: const Icon(Icons.movie, size: 100, color: Color(0xFF1E88E5)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Rating and year
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Color(0xFF1E88E5),
                                  size: 28,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  movie!.userRating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '/ 10',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: const Color(0xFFB7B9BD),
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0D47A1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${movie!.year}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Genres
                            if (movie!.genreNames.isNotEmpty) ...[
                              Wrap(
                                spacing: 8,
                                children: movie!.genreNames
                                    .map(
                                      (genre) => Chip(
                                        label: Text(genre),
                                        backgroundColor: const Color(0xFF23262C),
                                        side: const BorderSide(color: Color(0xFF1E88E5), width: 1),
                                      ),
                                    )
                                    .toList(),
                              ),
                              const SizedBox(height: 20),
                            ],
                            // Streaming services availability
                            if (movie!.sources.isNotEmpty) ...[
                              const Text(
                                'Available On',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: movie!.sources
                                    .map((source) => Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1E88E5).withValues(alpha: 0.15),
                                            border: Border.all(
                                              color: const Color(0xFF1E88E5),
                                              width: 1,
                                            ),
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                _getSourceIcon(source.type),
                                                size: 18,
                                                color: const Color(0xFF1E88E5),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                source.sourceName,
                                                style: const TextStyle(fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ))
                                    .toList(),
                              ),
                              const SizedBox(height: 20),
                            ],
                            // Synopsis
                            const Text(
                              'Synopsis',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              movie!.plotOverview,
                              style: const TextStyle(fontSize: 16, height: 1.5),
                            ),
                            // Trailer button if available
                            if (movie!.trailer != null) ...[
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: _openTrailer,
                                icon: const Icon(Icons.play_circle_outline),
                                label: const Text('Watch Trailer'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E88E5),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  IconData _getSourceIcon(String type) {
    switch (type.toLowerCase()) {
      case 'subscription':
        return Icons.subscriptions;
      case 'purchase':
        return Icons.shopping_cart;
      case 'rent':
        return Icons.videocam;
      default:
        return Icons.videocam;
    }
  }
}
