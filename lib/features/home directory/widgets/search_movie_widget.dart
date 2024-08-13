import 'dart:ui';
import 'package:cinetrack/core/widgets/form_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import '../../../core/res/app_images.dart';
import '../../../core/res/app_strings.dart';
import '../../../core/utils/app_color.dart';
import '../../../providers/movie_provider.dart';
import '../screens/movie_details_screen.dart';

class SearchMoviesBottomSheet extends StatelessWidget {
  const SearchMoviesBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final movieProvider = Provider.of<MovieProvider>(context);
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
        child: Container(
          padding: const EdgeInsets.all(12.0),
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: AppColor.bg.withOpacity(0.9),
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
          ),
          child: Column(
            children: [
              SizedBox(height: 28.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 42.h,
                    width: 42.w,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColor.fillColor.withOpacity(0.7)),
                    child: IconButton(
                      icon: const Icon(CupertinoIcons.xmark,
                          color: AppColor.whiteTextColor),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  SizedBox(width: 5.h),
                  Expanded(
                    child: FormText(
                      onChanged: (query) {
                        movieProvider.searchMovies(query);
                      },
                      textColor: AppColor.whiteTextColor,
                      hintText: "Search for movies...",
                      prefixIcon: const Icon(Remix.search_2_line),
                    ),
                  )
                ],
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: movieProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : movieProvider.searchedMovies.isEmpty
                        ? Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(AppImages.errorPicture),
                                Text(
                                  "Oops! Movie not available\n search another movie",
                                  style: TextStyle(
                                      fontFamily: AppStrings.poppins,
                                      fontSize: 16.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: movieProvider.searchedMovies.length,
                            itemBuilder: (context, index) {
                              final movie = movieProvider.searchedMovies[index];
                              return ListTile(
                                leading: movie.posterPath.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(15.r),
                                        child: Image.network(
                                          'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                                          width: 100.w,
                                          height: 100.h,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return const Icon(Icons.error);
                                          },
                                        ),
                                      )
                                    : const Icon(Icons.movie),
                                title: Text(
                                  movie.title,
                                  style: TextStyle(
                                      fontFamily: AppStrings.poppins,
                                      fontSize: 16.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500),
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
                                onTap: () async {
                                  Provider.of<MovieProvider>(context,
                                          listen: false)
                                      .fetchMovieDetails(movie.id);
                                  showModalBottomSheet(
                                    context: context,
                                    backgroundColor: Colors.transparent,
                                    builder: (context) =>
                                        MovieDetailBottomSheet(
                                            movieId: movie.id),
                                    isScrollControlled: true,
                                  );
                                },
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
