import 'dart:ui';
import 'package:cinetrack/core/res/app_strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/res/app_images.dart';
import '../../../core/utils/app_color.dart';
import '../../../models/movie_model.dart';
import '../../../providers/movie_provider.dart';
import '../widgets/adding_movie_to_wishlist_button.dart';

class MovieDetailBottomSheet extends StatefulWidget {
  final int movieId;

  const MovieDetailBottomSheet({super.key, required this.movieId});

  @override
  State<MovieDetailBottomSheet> createState() => _MovieDetailBottomSheetState();
}

class _MovieDetailBottomSheetState extends State<MovieDetailBottomSheet> {
  bool _isExpanded = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieProvider>().fetchWatchlist();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MovieProvider>(
      builder: (context, provider, child) {
        final movie = provider.movieDetails;

        if (provider.isLoading) {
          return ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
              child: Container(
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  color: AppColor.bg.withOpacity(0.9),
                  borderRadius:
                  BorderRadius.vertical(top: Radius.circular(16.r)),
                ),
                child: Padding(
                  padding:  EdgeInsets.all(8.sp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 50.h,
                      ),
                      Container(
                        height: 38.h,
                        width: 38.w,
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
                      SizedBox(
                        height: 250.h,
                      ),
                      const Center(
                        child: CircularProgressIndicator(
                          color: AppColor.primaryColor,
                          strokeWidth: 5.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        if (movie == null) {
          return Center(child: Text(provider.errorMessage));
        }

        return ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
            child: Container(
              height:
                  MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                color: AppColor.bg.withOpacity(0.9),
                borderRadius:
                     BorderRadius.vertical(top: Radius.circular(16.r)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 500.h,
                      child: Stack(
                        children: [
                          ShaderMask(
                            shaderCallback: (rect) {
                              return LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(1.0),
                                  Colors.black.withOpacity(0.0),
                                ],
                                stops: const [0.7, 1.9],
                              ).createShader(rect);
                            },
                            blendMode: BlendMode.dstIn,
                            child: Image.network(
                              'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                              fit: BoxFit.cover,
                              height: 490.h,
                              width: double.infinity,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                } else {
                                  return Container(
                                    width: double.infinity,
                                    height: 490.h,
                                    decoration: const BoxDecoration(
                                      color: AppColor.fillColor,
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                              },
                              errorBuilder: (BuildContext context, Object error,
                                  StackTrace? stackTrace) {
                                return Container(
                                  width: double.infinity,
                                  height: 490.h,
                                  decoration: const BoxDecoration(
                                    color: AppColor.fillColor,
                                  ),
                                  child: const Icon(Icons.error,
                                      color: Colors.red),
                                );
                              },
                            ),
                          ),
                          Positioned(
                            top: 30.h,
                            left: 10.w,
                            child: Container(
                              height: 38.h,
                              width: 38.w,
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
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding:  EdgeInsets.all(12.sp),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildRatingStars(movie.voteAverage),
                          Text(
                            'Status: ${movie.status}',
                            style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: AppStrings.poppins,
                                color: Colors.white),
                          ),
                          SizedBox(height: 5.h),
                          Text(
                            movie.title,
                            style: TextStyle(
                                fontSize: 26.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: AppStrings.poppins,
                                color: Colors.white),
                            maxLines: 2,
                          ),
                          SizedBox(height: 8.h),
                          _buildReleaseDate(movie.releaseDate),
                          SizedBox(height: 5.h),
                          _buildGenres(
                              movie.genres.map((genre) => genre.name).toList()),
                          SizedBox(height: 8.h),
                          _buildOverview(movie.overview),
                          SizedBox(height: 5.h),
                          WatchlistButton(
                            movieId: widget.movieId,
                            provider: provider,
                          ),
                          SizedBox(height: 8.h),
                          _buildCastAndCrew(movie.cast, 'Cast'),
                          SizedBox(height: 8.h),
                          Text(
                            'More Information',
                            style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: AppStrings.poppins,
                                color: Colors.white),
                          ),
                          SizedBox(height: 8.h),
                          _buildOriginalLanguage(movie.originalLanguage),
                          SizedBox(height: 8.h),
                          _buildBudget(movie.budget),
                          SizedBox(height: 8.h),
                          _buildRevenue(movie.revenue),
                          SizedBox(height: 8.h),
                          _buildProductionCountries(movie.productionCountries),
                          SizedBox(height: 8.h),
                          _buildSpokenLanguages(movie.spokenLanguages),
                          SizedBox(height: 8.h),
                          _buildRuntime(movie.runtime),
                          SizedBox(height: 8.h),
                          _buildOriginalLanguage(movie.originalLanguage),
                          SizedBox(height: 8.h),
                          SizedBox(height: 8.h),
                          _buildProductionCompanies(movie.productionCompanies),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRatingStars(double rating) {
    int fullStars = (rating / 2).floor(); // Full stars
    bool hasHalfStar = (rating / 2 - fullStars) > 0.5; // Half star
    int emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0); // Empty stars

    return Row(
      children: [
        ...List.generate(fullStars,
            (index) => const Icon(Icons.star, color: Colors.amber, size: 26)),
        if (hasHalfStar)
          const Icon(Icons.star_half, color: Colors.amber, size: 26),
        ...List.generate(
            emptyStars,
            (index) =>
                const Icon(Icons.star_border, color: Colors.amber, size: 26)),
        SizedBox(width: 8.w),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
              color: Colors.white,
              fontFamily: AppStrings.poppins,
              fontWeight: FontWeight.bold,
              fontSize: 18.sp),
        ),
      ],
    );
  }

  Widget _buildReleaseDate(String releaseDate) {
    final dateFormat = DateFormat('MMMM d, yyyy');
    final date = DateTime.parse(releaseDate);
    final formattedDate = dateFormat.format(date);
    return Row(
      children: [
        const Icon(Icons.calendar_today, color: Colors.amber, size: 20),
        // Calendar icon
        SizedBox(width: 8.w),
        Text(
          'Release Date: $formattedDate',
          style: TextStyle(
              color: Colors.white,
              fontFamily: AppStrings.poppins,
              fontWeight: FontWeight.w500,
              fontSize: 16.sp),
        ),
      ],
    );
  }

  Widget _buildGenres(List<String> genres) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: genres.map((genre) {
        return Text(
          '.$genre',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 15.sp,
              fontFamily: AppStrings.poppins),
        );
      }).toList(),
    );
  }

  Widget _buildOverview(String overview) {
    final bool isLongText = overview.length > 100;
    final String truncatedOverview =
        isLongText ? '${overview.substring(0, 100)}...' : overview;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview:',
          style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontFamily: AppStrings.poppins,
              fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.h),
        Text(
          _isExpanded ? overview : truncatedOverview,
          style: TextStyle(
              color: AppColor.subColor,
              fontSize: 15.sp,
              fontFamily: AppStrings.poppins,
              fontWeight: FontWeight.w500),
        ),
        if (isLongText)
          TextButton(
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Text(
              _isExpanded ? 'Read Less' : 'Read More',
              style: const TextStyle(
                  color: Colors.white,
                  fontFamily: AppStrings.poppins,
                  fontWeight: FontWeight.w500
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCastAndCrew(List<Cast> people, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
              fontSize: 20.sp,
              fontFamily: AppStrings.poppins,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          height: 200.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: people.length,
            itemBuilder: (context, index) {
              final person = people[index];
              return Container(
                width: 100.w,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15.r),
                      child: Image.network(
                        'https://image.tmdb.org/t/p/w500${person.profilePath}',
                        fit: BoxFit.cover,
                        height: 150.h,
                        width: 110.w,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          } else {
                            return Container(
                              height: 150.h,
                              width: 130.w,
                              decoration: const BoxDecoration(
                                color: AppColor.fillColor,
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 150.h,
                          width: 130.w,
                          decoration: const BoxDecoration(
                              color: AppColor.fillColor,
                              image: DecorationImage(
                                image: AssetImage(AppImages.moviePlaceholder),
                              )),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      person.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontFamily: AppStrings.poppins,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOriginalLanguage(String language) {
    return Row(
      children: [
        const Icon(Icons.language, color: Colors.blueAccent, size: 20),
        SizedBox(width: 8.w),
        Text(
          'Original Language: $language',
          style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontFamily: AppStrings.poppins,
              fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildBudget(int budget) {
    final double budgetAsDouble = budget.toDouble();
    final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');

    return Row(
      children: [
        const Icon(Icons.attach_money, color: Colors.green, size: 20),
        SizedBox(width: 8.w),
        Text(
          'Budget: ${currencyFormat.format(budgetAsDouble)}',
          style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontFamily: AppStrings.poppins,
              fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildRevenue(int budget) {
    final double budgetAsDouble = budget.toDouble();
    final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');

    return Row(
      children: [
        const Icon(Icons.attach_money, color: Colors.green, size: 20),
        SizedBox(width: 8.w),
        Text(
          'Revenue: ${currencyFormat.format(budgetAsDouble)}',
          style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontFamily: AppStrings.poppins,
              fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildProductionCompanies(List<ProductionCompany> companies) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Production Companies:',
          style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontFamily: AppStrings.poppins,
              fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: companies.length,
            itemBuilder: (context, index) {
              final company = companies[index];
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: company.logoPath != null
                    ? Image.network(
                        color: AppColor.primaryColor,
                        'https://image.tmdb.org/t/p/w500${company.logoPath}',
                        height: 60,
                        width: 100,
                      )
                    : Container(
                        width: 50.w,
                        height: 50.h,
                        color: AppColor.primaryColor,
                        child: Center(
                            child: Text(
                          company.name[0],
                          style: const TextStyle(
                              color: AppColor.subColor,
                              fontFamily: AppStrings.poppins,
                              fontWeight: FontWeight.w500),
                        )),
                      ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductionCountries(List<ProductionCountry> countries) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Production Countries:',
          style: TextStyle(
              color: Colors.white,
              fontSize: 17.sp,
              fontFamily: AppStrings.poppins,
              fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: countries.map((country) {
            return Text(
              country.name,
              style: TextStyle(
                  color: AppColor.subColor,
                  fontSize: 15.sp,
                  fontFamily: AppStrings.poppins,
                  fontWeight: FontWeight.w500),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSpokenLanguages(List<SpokenLanguage> languages) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Spoken Languages:',
          style: TextStyle(
              color: Colors.white,
              fontSize: 17.sp,
              fontFamily: AppStrings.poppins,
              fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: languages.map((language) {
            return Text(
              language.name,
              style: TextStyle(
                  color: AppColor.subColor,
                  fontSize: 15.sp,
                  fontFamily: AppStrings.poppins,
                  fontWeight: FontWeight.w500),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRuntime(int runtime) {
    final int hours = runtime ~/ 60;
    final int minutes = runtime % 60;

    return Row(
      children: [
        const Icon(Icons.access_time, color: Colors.orangeAccent, size: 20),
        SizedBox(width: 8.w),
        Text(
          'Runtime: ${hours}h ${minutes}m',
          style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontFamily: AppStrings.poppins,
              fontWeight: FontWeight.w600),
        ),
      ],
    );
  }


}
