import 'dart:ui';
import 'package:cinetrack/core/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:remixicon/remixicon.dart';
import 'package:provider/provider.dart';
import '../../../core/res/app_images.dart';
import '../../../core/res/app_strings.dart';
import '../../../providers/movie_provider.dart';
import 'movie_details_screen.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  late Future<void> _initializationFuture;

  @override
  void initState() {
    super.initState();
    _initializationFuture = _initializeWatchlist();
  }

  Future<void> _initializeWatchlist() async {
    final movieProvider = Provider.of<MovieProvider>(context, listen: false);
    await movieProvider.fetchWatchlist();
    await movieProvider.preloadMovieDetails();
  }

  @override
  Widget build(BuildContext context) {
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
              surfaceTintColor: Colors.transparent,
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                "My WatchList",
                style: TextStyle(
                    fontFamily: AppStrings.poppins,
                    fontSize: 20.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<void>(
        future: _initializationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text(
              'Error: ${snapshot.error}',
              style: TextStyle(
                  fontFamily: AppStrings.poppins,
                  fontSize: 20.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ));
          } else {
            return Consumer<MovieProvider>(
              builder: (context, movieProvider, child) {
                final watchlist = movieProvider.watchlist;
                if (watchlist.isEmpty) {
                  return Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(AppImages.errorPicture),
                        Text(
                          "Oops! Your Watchlist is empty\n add movies to your watchlist!",
                          style: TextStyle(
                              fontFamily: AppStrings.poppins,
                              fontSize: 16.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: watchlist.length,
                  itemBuilder: (context, index) {
                    final movieId = watchlist[index];
                    final movie = movieProvider.getMovieFromCache(movieId);
                    if (movie == null) {
                      return const ListTile(title: Text('Loading...'));
                    }
                    return ListTile(
                      leading: movie.posterPath.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(15.r),
                              child: Image.network(
                                'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                                width: 130.w,
                                height: 100.h,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.error);
                                },
                              ),
                            )
                          : const Icon(Icons.movie),
                      title: Text(
                        movie.title,
                        style: TextStyle(
                            fontFamily: AppStrings.poppins,
                            fontSize: 17.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        movie.overview,
                        style: TextStyle(
                            fontFamily: AppStrings.poppins,
                            fontSize: 14.sp,
                            color: AppColor.subColor,
                            fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        icon:  const Icon(Remix.delete_bin_line, color: Colors.red),
                        onPressed: () {
                          movieProvider.toggleWatchlist(movieId, context);
                        },
                      ),
                      onTap: () {
                        Provider.of<MovieProvider>(context, listen: false)
                            .fetchMovieDetails(movie.id);
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (context) =>
                              MovieDetailBottomSheet(movieId: movieId),
                          isScrollControlled: true,
                        );
                      },
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
