import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/movie_model.dart';

class TmdbApi {
  static const String _apiKey = ' ';
  // your api key above
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  final http.Client client;
  final Duration _timeoutDuration = const Duration(seconds: 10);

  TmdbApi({required this.client});

  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    if (response.statusCode == 200) {
      try {
        return json.decode(response.body);
      } catch (e) {
        throw Exception('Failed to parse response: $e');
      }
    } else {
      switch (response.statusCode) {
        case 400:
          throw Exception('Bad request: ${response.body}');
        case 401:
          throw Exception('Unauthorized: ${response.body}');
        case 404:
          throw Exception('Not found: ${response.body}');
        case 500:
          throw Exception('Server error: ${response.body}');
        default:
          throw Exception('Failed to load data: ${response.body}');
      }
    }
  }

  Future<List<Movie>> getPopularMovies({int page = 1}) async {
    final url = '$_baseUrl/movie/popular?api_key=$_apiKey&page=$page';
    return _fetchMovies(url);
  }

  Future<List<Movie>> getTrendingMovies() async {
    const url = '$_baseUrl/trending/movie/day?api_key=$_apiKey';
    return _fetchMovies(url);
  }

  Future<List<Movie>> getLatestMovies() async {
    const url = '$_baseUrl/movie/now_playing?api_key=$_apiKey';
    return _fetchMovies(url);
  }

  Future<List<Movie>> getUpcomingMovies() async {
    const url = '$_baseUrl/movie/upcoming?api_key=$_apiKey';
    return _fetchMovies(url);
  }

  Future<List<Movie>> getTopRatedMovies() async {
    const url = '$_baseUrl/movie/top_rated?api_key=$_apiKey';
    return _fetchMovies(url);
  }

  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    final url = '$_baseUrl/search/movie?api_key=$_apiKey&query=$query&page=$page';
    return _fetchMovies(url);
  }

  Future<Movie> getMovieDetails(int movieId) async {
    final url = '$_baseUrl/movie/$movieId?api_key=$_apiKey&append_to_response=credits';
    try {
      final response = await client.get(Uri.parse(url)).timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final movie = Movie.fromJson(data);

        if (data['credits'] != null) {
          final credits = data['credits'];
          movie.cast = (credits['cast'] as List<dynamic>?)
              ?.map((castMember) => Cast.fromJson(castMember))
              .toList() ??
              [];
          movie.crew = (credits['crew'] as List<dynamic>?)
              ?.map((crewMember) => Crew.fromJson(crewMember))
              .toList() ??
              [];
        } else {
        }

        return movie;
      } else {
        throw Exception('Failed to load movie details: ${response.statusCode}');
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<List<Movie>> _fetchMovies(String url) async {
    try {
      final response = await client
          .get(Uri.parse(url))
          .timeout(_timeoutDuration);
      final data = await _handleResponse(response);

      final results = data['results'] as List<dynamic>?;
      if (results == null) {
        throw Exception('No results found.');
      }
      return results.map((movieData) => Movie.fromJson(movieData)).toList();
    } catch (error) {
      throw Exception('Failed to fetch movies: $error');
    }
  }

}