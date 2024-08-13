import 'dart:ui';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cinetrack/core/res/app_images.dart';
import 'package:cinetrack/core/res/app_strings.dart';
import 'package:cinetrack/core/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../../../models/movie_model.dart';
import '../../../providers/movie_provider.dart';
import '../../../services/api/tmdb_api.dart';
import '../../auth directory/login directory/screens/login_screen.dart';
import '../widgets/popular_movies_palette_generator_widget.dart';
import '../widgets/search_movie_widget.dart';
import 'movie_details_screen.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  final String? token;

  const HomeScreen({super.key, required this.token});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late Future<Map<String, String>> _userProfileFuture;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  void _setError(String message) {
    setState(() {
      _hasError = true;
      _errorMessage = message;
    });
  }

  @override
  void initState() {
    super.initState();
    _userProfileFuture = fetchUserProfile();
    _loadData();
  }

  bool _mounted = true;

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  void _safeSetState(VoidCallback fn) {
    if (_mounted) setState(fn);
  }

  Future<void> _loadData() async {
    try {
      final movieProvider = Provider.of<MovieProvider>(context, listen: false);
      await Future.wait([
        movieProvider.fetchTrendingMovies(),
        movieProvider.fetchUpcomingMovies(),
        movieProvider.fetchLatestMovies(),
        movieProvider.fetchTopRatedMovies(),
      ]);
    } catch (e) {
      _safeSetState(() {
        _hasError = true;
        _errorMessage = 'Failed to load movies: $e';
      });
    } finally {
      _safeSetState(() => _isLoading = false);
    }
  }

  Future<Map<String, String>> fetchUserProfile() async {
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token!);
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString("userName") ?? "User";
    final profilePicture = jwtDecodedToken['profilePicture'] ?? '';
    final email = jwtDecodedToken['email'] ?? 'Email not found';
    return {
      'userName': userName,
      'profilePicture': profilePicture,
      'email': email,
    };
  }

  @override
  Widget build(BuildContext context) {
    final client = http.Client();
    final tmdbApi = TmdbApi(client: client);
    if (widget.token != null && JwtDecoder.isExpired(widget.token!)) {
      return const LoginScreen();
    }

    if (_hasError) {
      return Scaffold(
        backgroundColor: AppColor.bg,
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(AppImages.errorPicture),
              Text(
                "Oops! we ran into an issue with our server.\nPlease try again later.",
                style: TextStyle(
                    fontFamily: AppStrings.poppins,
                    fontSize: 16.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColor.primaryColor,
      backgroundColor: AppColor.bg,
      triggerMode: RefreshIndicatorTriggerMode.onEdge,
      onRefresh: () async {
        await fetchUserProfile();
        await _loadData();
      },
      child: FutureBuilder<Map<String, String>>(
        future: fetchUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: AppColor.bg,
              body: Center(
                  child: CircularProgressIndicator(
                color: AppColor.primaryColor,
              )),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              backgroundColor: AppColor.bg,
              body: Center(child: errorMessage(snapshot)),
            );
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            final profilePictureUrl = data['profilePicture'] ?? '';
            final userName = data['userName'] ?? 'User';
            final email = data['email'] ?? 'No email';

            return Scaffold(
              extendBodyBehindAppBar: true,
              backgroundColor: AppColor.bg,
              appBar: PreferredSize(
                preferredSize: Size(
                  double.infinity,
                  56.h,
                ),
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: AppBar(
                      backgroundColor: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                      elevation: 0,
                      title: Row(
                        children: [
                          Container(
                            height: 58.h,
                            width: 58.w,
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: AssetImage(
                                      AppImages.defaultProfilePicture),
                                )),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(28.r),
                              child: Image.network(
                                profilePictureUrl,
                                filterQuality: FilterQuality.high,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child;
                                  } else {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                },
                                errorBuilder: (BuildContext context,
                                    Object error, StackTrace? stackTrace) {
                                  return const Icon(Icons.error,
                                      color: Colors.red);
                                },
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              userName,
                              style: TextStyle(
                                  fontFamily: AppStrings.poppins,
                                  fontSize: 18.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        Container(
                          height: 38.h,
                          width: 38.w,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColor.fillColor.withOpacity(0.4)),
                          child: IconButton(
                            icon: const Icon(Remix.search_line,
                                color: AppColor.whiteTextColor),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) =>
                                    ChangeNotifierProvider.value(
                                  value: Provider.of<MovieProvider>(context,
                                      listen: false),
                                  child: const SearchMoviesBottomSheet(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: MovieSection(token: widget.token!)),
                    SizedBox(
                      height: 8.h,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMovieSection(
                            context,
                            title: 'Trending Movies',
                            provider: MovieProvider(tmdbApi),
                            movies: Provider.of<MovieProvider>(context)
                                .trendingMovies,
                          ),
                          SizedBox(height: 8.h),
                          _buildMovieSection(
                            context,
                            title: 'Upcoming Movies',
                            provider: MovieProvider(tmdbApi),
                            movies: Provider.of<MovieProvider>(context)
                                .upcomingMovies,
                          ),
                          SizedBox(height: 8.h),
                          _buildMovieSection(
                            context,
                            title: 'Latest Movies',
                            provider: MovieProvider(tmdbApi),
                            movies: Provider.of<MovieProvider>(context)
                                .latestMovies,
                          ),
                          SizedBox(height: 8.h),
                          _buildMovieSection(
                            context,
                            title: 'Top Rate Movies',
                            provider: MovieProvider(tmdbApi),
                            movies: Provider.of<MovieProvider>(context)
                                .topRatedMovies,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          } else {
            return const Scaffold(
              body: Center(child: Text('No data')),
            );
          }
        },
      ),
    );
  }

  Widget _buildMovieSection(BuildContext context,
      {required String title,
      required List<Movie> movies,
      required MovieProvider provider}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            color: AppColor.whiteTextColor,
            fontWeight: FontWeight.bold,
            fontFamily: AppStrings.poppins,
          ),
        ),
        SizedBox(height: 8.h),
        Consumer<MovieProvider>(
          builder: (context, movieProvider, child) {
            if (movies.isEmpty) {
              return shimmerPlaceHolder();
            } else {
              return CarouselSlider(
                options: CarouselOptions(
                  height: 250.h,
                  enlargeCenterPage: false,
                  autoPlay: false,
                  initialPage: 0,
                  padEnds: false,
                  aspectRatio: 16 / 9,
                  enableInfiniteScroll: false,
                  viewportFraction: 0.4,
                ),
                items: movies.map((movie) {
                  return Builder(
                    builder: (BuildContext context) {
                      return carouselContainer(movie);
                    },
                  );
                }).toList(),
              );
            }
          },
        ),
      ],
    );
  }

  Widget shimmerPlaceHolder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[500]!,
      child: CarouselSlider(
        options: CarouselOptions(
          height: 200.h,
          enlargeCenterPage: false,
          autoPlay: false,
          initialPage: 0,
          aspectRatio: 16 / 9,
          enableInfiniteScroll: true,
          viewportFraction: 0.4,
        ),
        items: List.generate(3, (index) {
          return Container(
            width: 200.w,
            margin: const EdgeInsets.symmetric(horizontal: 5.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.circular(20.r),
            ),
          );
        }),
      ),
    );
  }

  Widget carouselContainer(Movie movie) {
    return GestureDetector(
      onTap: () {
        Provider.of<MovieProvider>(context, listen: false)
            .fetchMovieDetails(movie.id);
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (context) => MovieDetailBottomSheet(movieId: movie.id),
          isScrollControlled: true,
        );
      },
      child: Container(
        width: 200.w,
        margin: const EdgeInsets.symmetric(horizontal: 5.0),
        decoration: const BoxDecoration(color: Colors.transparent),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColor.fillColor,
                borderRadius: BorderRadius.circular(15.r),
                image: const DecorationImage(
                  image: AssetImage(AppImages.moviePlaceholder),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.r),
                child: Image.network(
                  'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                  fit: BoxFit.cover,
                  height: 200.h,
                  errorBuilder: (BuildContext context, Object error,
                      StackTrace? stackTrace) {
                    return Container(
                      width: 200.w,
                      height: 200.h,
                      decoration: BoxDecoration(
                        color: AppColor.fillColor,
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                      child: const Icon(Icons.error, color: Colors.red),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              movie.title ?? 'No Title',
              style: TextStyle(
                fontSize: 15.sp,
                color: AppColor.whiteTextColor,
                fontWeight: FontWeight.w500,
                fontFamily: AppStrings.poppins,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget errorMessage(AsyncSnapshot<Map<String, String>> snapshot) {
    return Text(
      'Error: ${snapshot.error}',
      textAlign: TextAlign.center,
      style: TextStyle(
          color: AppColor.whiteTextColor,
          fontFamily: AppStrings.poppins,
          fontSize: 20.sp),
    );
  }
}
