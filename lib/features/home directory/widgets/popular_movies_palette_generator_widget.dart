import 'package:carousel_slider/carousel_slider.dart';
import 'package:cinetrack/core/res/app_strings.dart';
import 'package:cinetrack/core/utils/app_color.dart';
import 'package:cinetrack/features/home%20directory/widgets/tmdb_loading_shimmer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../providers/movie_provider.dart';
import '../screens/movie_details_screen.dart';
import 'adding_movie_to_wishlist_button.dart';

class MovieSection extends StatefulWidget {
  final String token;

  const MovieSection({super.key, required this.token});

  @override
  State<MovieSection> createState() => _MovieSectionState();
}

class _MovieSectionState extends State<MovieSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int _currentIndex = 0;
  var backgroundColor = AppColor.bg;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    final movieProvider = Provider.of<MovieProvider>(context, listen: false);
    movieProvider.fetchPopularMovies();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateBackgroundColor(Color color) {
    setState(() {
      backgroundColor = color;
    });
    _animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MovieProvider>(
      builder: (context, movieProvider, child) {
        if (movieProvider.popularMovies.isEmpty) {
          if (movieProvider.errorMessage.isNotEmpty) {
            return Center(child: Text('Error: ${movieProvider.errorMessage}'));
          } else {
            return YourLoadingWidget(child: Container());
          }
        }

        final movies = movieProvider.popularMovies;
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.9),
                  ],
                  stops: const [0.6, 0.8, 1.5],
                ).createShader(bounds);
              },
              blendMode: BlendMode.srcATop,
              child: Container(
                height: 660.h,
                padding: const EdgeInsets.only(top: 60),
                color: Color.lerp(
                    backgroundColor,
                    movies[_currentIndex].dominantColor.withOpacity(0.5),
                    _animation.value),
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: 420.h,
                    viewportFraction: 0.8,
                    enlargeCenterPage: true,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 2),
                    enlargeStrategy: CenterPageEnlargeStrategy.height,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentIndex = index;
                      });
                      _updateBackgroundColor(
                          movies[index].dominantColor);
                    },
                  ),
                  items: movies.map((movie) {
                    return Builder(
                      builder: (BuildContext context) {
                        return GestureDetector(
                          onTap: () {
                            Provider.of<MovieProvider>(context, listen: false)
                                .fetchMovieDetails(movie.id);
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (context) =>
                                  MovieDetailBottomSheet(movieId: movie.id),
                              isScrollControlled:
                                  true,
                            );
                          },
                          child: Hero(
                            tag: 'movie-${movie.id}',
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 5.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20.r),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.network(
                                      'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                                      fit: BoxFit.cover,
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            colors: [
                                              Colors.black.withOpacity(0.8),
                                              Colors.transparent
                                            ],
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10.0, horizontal: 20.0),
                                        child: Column(
                                          children: [
                                            Text(movie.title,
                                                style: TextStyle(
                                                    fontFamily:
                                                        AppStrings.poppins,
                                                    fontSize: 20.sp,
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                overflow:
                                                    TextOverflow.ellipsis),
                                            SizedBox(
                                              height: 7.h,
                                            ),
                                            WatchlistButton(
                                              movieId: movie.id,
                                              provider: movieProvider,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
