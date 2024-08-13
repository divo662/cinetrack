import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/config/config_file.dart';
import '../features/home directory/screens/movie_details_screen.dart';
import '../models/movie_model.dart';
import '../services/api/tmdb_api.dart';
import 'package:http/http.dart' as http;

class MovieProvider extends ChangeNotifier {
  final TmdbApi _api;

  final List<Movie> _trendingMovies = [];
  final List<Movie> _upcomingMovies = [];
  final List<Movie> _latestMovies = [];
  final List<Movie> _topRatedMovies = [];
  final List<Movie> _popularMovies = [];
  List<Movie> _searchedMovies = [];
  Movie? _movieDetails;

  List<Movie> get trendingMovies => _trendingMovies;
  List<Movie> get upcomingMovies => _upcomingMovies;
  List<Movie> get latestMovies => _latestMovies;
  List<Movie> get topRatedMovies => _topRatedMovies;
  List<Movie> get popularMovies => _popularMovies;
  List<Movie> get searchedMovies => _searchedMovies;
  Movie? get movieDetails => _movieDetails;
  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  MovieProvider(this._api);

   Future<void> _fetchMovies(Future<List<Movie>> Function() fetchFunction,
      List<Movie> movieList) async {
    _isLoading = true;
    try {
      final movies = await fetchFunction();
      final coloredMovies = await _addColorPalettes(movies);
      movieList.clear();
      movieList.addAll(coloredMovies);
      _errorMessage = '';
    } catch (error) {
      _errorMessage = 'Failed to load movies: $error';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchPopularMovies() => _fetchMovies(
        _api.getPopularMovies,
        _popularMovies,
      );

  Future<void> fetchTrendingMovies() => _fetchMovies(
        _api.getTrendingMovies,
        _trendingMovies,
      );

  Future<void> fetchUpcomingMovies() => _fetchMovies(
        _api.getUpcomingMovies,
        _upcomingMovies,
      );

  Future<void> fetchLatestMovies() => _fetchMovies(
        _api.getLatestMovies,
        _latestMovies,
      );

  Future<void> fetchTopRatedMovies() => _fetchMovies(
        _api.getTopRatedMovies,
        _topRatedMovies,
      );

  Future<void> fetchMovieDetails(int movieId) async {
    _setLoading(true);
    try {
      _movieDetails = await _api.getMovieDetails(movieId);
      _errorMessage = '';
    } catch (error) {
      _setErrorMessage('Failed to load movie details: $error');
    }
    _setLoading(false);
  }

  Future<void> searchMovies(String query, {int page = 1}) async {
    _setLoading(true);
    try {
      _searchedMovies = await _api.searchMovies(query, page: page);
      _errorMessage = '';
    } catch (error) {
      _setErrorMessage('Failed to search movies: $error');
    }
    _setLoading(false);
  }

  Future<List<Movie>> _addColorPalettes(List<Movie> movies) async {
    for (var movie in movies) {
      final imageUrl = 'https://image.tmdb.org/t/p/w500${movie.posterPath}';
      final colorPalette = await fetchColorPalette(imageUrl);
      if (colorPalette.isNotEmpty) {
        movie.dominantColor = colorPalette.first;
        movie.textColor = colorPalette.last;
      }
    }
    return movies;
  }

  Future<List<Color>> fetchColorPalette(String imageUrl) async {
    try {
      final response = await http.post(
        Uri.parse(extractColorsEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'imageUrl': imageUrl}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<String> colorHexList =
            List<String>.from(data['colorPalette']);
        return colorHexList
            .map((hex) => Color(int.parse(hex.replaceAll('#', '0xff'))))
            .toList();
      } else {
        throw Exception('Failed to fetch color palette');
      }
    } catch (e) {
      return [];
    }
  }

  void showMovieDetails(BuildContext context, int movieId) async {
    await fetchMovieDetails(movieId);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovieDetailBottomSheet(movieId: movieId),
      ),
    );
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setErrorMessage(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  List<int> _watchlist = [];
  List<int> get watchlist => _watchlist;
  final Map<int, Movie> _movieCache = {};

  Future<List<int>> fetchWatchlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        throw Exception('User not logged in');
      }

      final response = await http.get(
        Uri.parse('$getWatchListEndpoint?userId=$userId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _watchlist = data.map<int>((item) {
          try {
            return int.parse(item['movieId'].toString());
          } catch (e) {
            return 0;
          }
        }).toList();
        notifyListeners();
        return _watchlist.toList();
      } else {
        throw Exception('Failed to fetch watchlist');
      }
    } catch (error) {
      return [];
    }
  }

  bool isMovieInWatchlist(int movieId) {
    return _watchlist.contains(movieId);
  }

  Future<Movie> getMovieDetails(int movieId) async {
    try {
      final movie = await _api.getMovieDetails(movieId);
      return movie;
    } catch (error) {
      rethrow;
    }
  }

  Future<void> preloadMovieDetails() async {
    for (final movieId in _watchlist) {
      if (!_movieCache.containsKey(movieId)) {
        try {
          final movie = await getMovieDetails(movieId);
          _movieCache[movieId] = movie;
          notifyListeners();
        } catch (e) {
          rethrow;
        }
      }
    }
  }

  Movie? getMovieFromCache(int movieId) {
    return _movieCache[movieId];
  }

  Future<void> toggleWatchlist(int movieId, BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        return;
      }

      final isInWatchlist = _watchlist.contains(movieId);
      final endpoint =
          isInWatchlist ? removeWatchListEndpoint : addToWatchListEndpoint;

      final response = await http.post(
        Uri.parse(endpoint),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          'userId': userId,
          'movieId': movieId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchWatchlist();
        _showSnackBar(
            isInWatchlist ? 'Removed from watchlist' : 'Added to watchlist',
            context);
      } else {
        _showSnackBar('Failed to update watchlist: ${response.body}', context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to update watchlist: ${response.body}')),
        );
      }
    } catch (error) {
      _showSnackBar('An error occurred: $error', context);
    }
  }

  Future<void> addToWatchlist(int movieId, BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        return;
      }

      final response = await http.post(
        Uri.parse(addToWatchListEndpoint),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          'userId': userId,
          'movieId': movieId,
        }),
      );

      if (response.statusCode == 201) {
        final watchlistItem = jsonDecode(response.body);
        await fetchWatchlist();
        _showSnackBar('Added to watchlist', context);
      } else {
        _showSnackBar('Failed to add to watchlist: ${response.body}', context);
      }
    } catch (error) {
      _showSnackBar("'An error occurred: $error'", context);
    }
  }

  void _showSnackBar(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        dismissDirection: DismissDirection.startToEnd,
        content: Container(
          width: 190,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(45),
            color: Colors.redAccent,
          ),
          child: Center(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
            ),
          ),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
