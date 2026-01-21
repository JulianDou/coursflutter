# CanIWatch - Streaming Service Movie Finder

## Overview

CanIWatch is a Flutter mobile application that helps users discover movies available on their selected streaming services. Instead of browsing through all movies, users can choose which streaming platforms they subscribe to and see only movies available on those services.

## Key Features

### 1. Streaming Service Selection
- **Settings Page**: Users can access a beautiful grid view of all available streaming services
- **Multi-select**: Choose one or multiple streaming services
- **Service Logos**: View streaming service logos and names
- **Easy Management**: Add or remove services with a single tap

### 2. Smart Movie Filtering
- **Service-Based Filtering**: Display only movies available on selected streaming services
- **Search Functionality**: Search for specific movies by title
- **Search Results**: Automatically filter search results based on selected services

### 3. Movie Details & Availability
- **Streaming Availability**: See exactly which streaming services have each movie
- **Service Types**: View the type of availability:
  - 🔄 Subscription
  - 🛒 Purchase
  - 🎥 Rent
- **Movie Information**: Rating, release year, genres, plot synopsis
- **Trailer Links**: Watch trailers directly from the app

### 4. Favorites System
- **Save Favorites**: Mark your favorite movies
- **Dedicated Favorites Page**: Access all saved favorites from one place
- **Persistent Selection**: Favorites are maintained during your session

## Architecture

### Models
- **MovieListItem**: Simplified movie object for lists
- **Movie**: Complete movie details including streaming sources
- **StreamingService**: Streaming platform information (name, logo, ID)
- **Source**: Specific streaming availability details (type, platforms)

### Services
- **MovieService**: Handles all API calls to Watchmode:
  - `getMovies()`: Fetch popular movies
  - `getMovieDetails()`: Get complete movie information
  - `getStreamingServices()`: Fetch all available streaming services
  - `searchMovies()`: Search movies by title

### Pages
- **MovieListPage**: Main page showing filtered movies with search bar
- **StreamingServiceSelector**: Service selection interface
- **MovieDetailPage**: Detailed movie information with availability
- **FavoritesPage**: Display saved favorite movies

## Technical Stack

- **Framework**: Flutter 3.10.7+
- **API**: Watchmode API v1
- **HTTP Client**: Dio 5.9.0
- **Launcher**: url_launcher 6.3.2
- **Design**: Material Design 3

## Setup Instructions

### Prerequisites
- Flutter SDK (3.10.7 or higher)
- Dart SDK
- Watchmode API Key (get one at https://api.watchmode.com/)

### Installation

1. Navigate to the project directory:
```bash
cd tp4_doutreligne_julian
```

2. Get dependencies:
```bash
flutter pub get
```

3. Run the app with your API key:
```bash
flutter run --dart-define=WATCHMODE_API_KEY=your_api_key_here
```

## App Flow

1. **Launch**: App opens with available movies list (no filter applied)
2. **Select Services**: Tap settings icon → Choose streaming services
3. **View Filtered Movies**: See only movies on selected services
4. **Search**: Use search bar to find specific movies
5. **View Details**: Tap a movie to see full details and streaming availability
6. **Save Favorites**: Heart icon to add/remove from favorites

## API Integration

The app uses the Watchmode API for:
- Fetching streaming services: `GET /v1/sources/`
- Getting movie lists: `GET /v1/list-titles/`
- Movie details with sources: `GET /v1/title/{id}/details/`
- Search movies: `GET /v1/search/`

## Color Scheme

- **Primary Blue**: #1E88E5 (main accent)
- **Secondary Blue**: #0D47A1 (darker shade)
- **Dark Background**: #111317
- **Surface**: #1A1C20
- **Text**: #EAAE2 (light color on dark background)

## Future Enhancements

- [ ] Persist user's selected services locally
- [ ] Add watchlist with notifications
- [ ] Filter by multiple criteria (year, genre, rating)
- [ ] Add user ratings and reviews
- [ ] Support for TV shows
- [ ] Dark/Light theme toggle
- [ ] Multiple language support

## Testing

Run the test suite:
```bash
flutter test
```

Test files include:
- `test/models/movie_test.dart`: Model parsing tests
- `test/widgets/movie_list_card_test.dart`: Widget tests
- `test/widget_test.dart`: Integration tests

## Troubleshooting

### "API Key Missing" Error
Make sure you're running the app with the Watchmode API key:
```bash
flutter run --dart-define=WATCHMODE_API_KEY=your_key
```

### No Movies Displaying
- Verify your API key is valid
- Check your internet connection
- Ensure Watchmode API is accessible

### Movies Not Filtering
- Select at least one streaming service from the settings
- Check that the Watchmode API is returning source data

## Project Structure

```
lib/
├── main.dart                           # App entry point
├── models/
│   ├── movie.dart                     # Movie and MovieListItem models
│   └── streaming_service.dart         # StreamingService and Source models
├── pages/
│   ├── movie_list_page.dart           # Main movies list with search
│   ├── movie_detail_page.dart         # Movie details and availability
│   └── streaming_service_selector.dart # Service selection interface
└── services/
    └── movie_service.dart             # Watchmode API integration
```

## License

This project is for educational purposes.

## Credits

- Built with Flutter
- Data provided by Watchmode API
- Icons from Material Design Icons

---

**Happy Watching!** 🎬🍿
