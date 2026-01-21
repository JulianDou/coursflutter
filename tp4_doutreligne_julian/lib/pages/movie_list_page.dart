import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/movie_service.dart';
import 'movie_detail_page.dart';
import 'streaming_service_selector.dart';

class MovieListPage extends StatefulWidget {
  final MovieService movieService;

  const MovieListPage({super.key, required this.movieService});

  @override
  State<MovieListPage> createState() => _MovieListPageState();
}

class _MovieListPageState extends State<MovieListPage> {
  List<MovieListItem> allMovies = [];
  List<MovieListItem> filteredMovies = [];
  Map<int, MovieListItem> movieCache = {}; // Cache all movies by ID
  Set<int> selectedServiceIds = {};
  bool isLoading = true;
  String? errorMessage;
  final Set<int> favorites = {};
  final TextEditingController _searchController = TextEditingController();
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadMovies();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMovies() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final loadedMovies = await widget.movieService.getMovies(
        limit: 30,
        sourceIds: selectedServiceIds.toList(),
      );
      setState(() {
        allMovies = loadedMovies;
        // Cache all loaded movies
        for (var movie in loadedMovies) {
          movieCache[movie.id] = movie;
        }
        _applyFilters();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _refreshMovies() async {
    _searchController.clear();
    setState(() {
      isSearching = false;
      errorMessage = null;
    });
    await _loadMovies();
  }

  void _onSearchChanged() {
    if (_searchController.text.isEmpty) {
      setState(() {
        isSearching = false;
        _applyFilters();
      });
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        isSearching = false;
        _applyFilters();
      });
      return;
    }

    setState(() {
      isSearching = true;
      isLoading = true;
    });

    try {
      final searchResults = await widget.movieService.searchMovies(
        query,
        limit: 20,
        sourceIds: selectedServiceIds.toList(),
      );
      setState(() {
        allMovies = searchResults;
        // Cache all search results
        for (var movie in searchResults) {
          movieCache[movie.id] = movie;
        }
        _applyFilters();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Search error: $e';
        isLoading = false;
      });
    }
  }

  void _applyFilters() {
    // Backend filters by source_ids; keep local list aligned
    filteredMovies = List<MovieListItem>.from(allMovies);
  }

  void _onServicesSelected(Set<int> serviceIds) {
    setState(() {
      selectedServiceIds = serviceIds;
      _applyFilters();
    });
  }

  void toggleFavorite(int movieId) {
    setState(() {
      favorites.contains(movieId)
          ? favorites.remove(movieId)
          : favorites.add(movieId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎬 CanIWatch'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshMovies,
            tooltip: 'Refresh movies',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StreamingServiceSelector(
                  movieService: widget.movieService,
                  selectedServiceIds: selectedServiceIds,
                  onServicesSelected: _onServicesSelected,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FavoritesPage(
                  movieService: widget.movieService,
                  favorites: favorites,
                  movieCache: movieCache,
                  toggleFavorite: toggleFavorite,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search movies...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            isSearching = false;
                            _applyFilters();
                          });
                        },
                      )
                    : null,
              ),
              onSubmitted: (value) => _performSearch(value),
            ),
          ),
          if (selectedServiceIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Wrap(
                spacing: 8,
                children: selectedServiceIds
                    .map((id) => Chip(
                          label: Text('Service ID: $id'),
                          onDeleted: () {
                            setState(() {
                              selectedServiceIds.remove(id);
                              _applyFilters();
                            });
                          },
                        ))
                    .toList(),
              ),
            ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline,
                                size: 60, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(errorMessage!, textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadMovies,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : filteredMovies.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isSearching
                                      ? Icons.search_off
                                      : Icons.movie_filter,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                Text(isSearching
                                    ? 'No movies found'
                                    : 'No movies available for your selected services'),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredMovies.length,
                            itemBuilder: (context, index) => MovieListCard(
                              movieService: widget.movieService,
                              movie: filteredMovies[index],
                              isFavorite: favorites
                                  .contains(filteredMovies[index].id),
                              onFavoriteTap: () =>
                                  toggleFavorite(filteredMovies[index].id),
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class FavoritesPage extends StatefulWidget {
  final MovieService movieService;
  final Set<int> favorites;
  final Map<int, MovieListItem> movieCache;
  final Function(int) toggleFavorite;

  const FavoritesPage({
    super.key,
    required this.movieService,
    required this.favorites,
    required this.movieCache,
    required this.toggleFavorite,
  });

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  Widget build(BuildContext context) {
    final favoriteMovies = widget.favorites
        .where((id) => widget.movieCache.containsKey(id))
        .map((id) => widget.movieCache[id]!)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('❤️ My Favorites'),
      ),
      body: favoriteMovies.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No favorite movies yet'),
                ],
              ),
            )
          : ListView.builder(
              itemCount: favoriteMovies.length,
              itemBuilder: (context, index) => MovieListCard(
                movieService: widget.movieService,
                movie: favoriteMovies[index],
                isFavorite: true,
                onFavoriteTap: () =>
                    widget.toggleFavorite(favoriteMovies[index].id),
              ),
            ),
    );
  }
}

class MovieListCard extends StatelessWidget {
  final MovieService movieService;
  final MovieListItem movie;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;
  final IconData? favoriteIcon;

  const MovieListCard({
    super.key,
    required this.movieService,
    required this.movie,
    required this.isFavorite,
    required this.onFavoriteTap,
    this.favoriteIcon,
  });

  // Generates a color based on the first letter of the title
  Color _getColorFromLetter(String title) {
    if (title.isEmpty) return Colors.grey;

    final letter = title[0].toUpperCase();
    final colorIndex = letter.codeUnitAt(0) % 10;

    const colors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.teal,
      Colors.green,
      Colors.orange,
      Colors.brown,
    ];

    return colors[colorIndex];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MovieDetailPage(
              movieService: movieService,
              movieId: movie.id,
            ),
          ),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: _getColorFromLetter(movie.title),
            child: Text(
              movie.title.isNotEmpty ? movie.title[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          title: Text(movie.title),
          subtitle: Text('Year: ${movie.year}'),
          trailing: IconButton(
            icon: Icon(
              favoriteIcon ?? (isFavorite ? Icons.favorite : Icons.favorite_border),
              color: isFavorite && favoriteIcon == null ? Colors.red : null,
            ),
            onPressed: onFavoriteTap,
          ),
        ),
      ),
    );
  }
}
