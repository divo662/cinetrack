import 'package:cinetrack/core/res/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../providers/movie_provider.dart';

class WatchlistButton extends StatefulWidget {
  final int movieId;
  final MovieProvider provider;

  const WatchlistButton(
      {super.key, required this.movieId, required this.provider});

  @override
  State<WatchlistButton> createState() => _WatchlistButtonState();
}

class _WatchlistButtonState extends State<WatchlistButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isLoading = false;
  bool _isAdded = false;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _checkWatchlistStatus();
  }

  void _checkWatchlistStatus() {
    setState(() {
      _isAdded = widget.provider.isMovieInWatchlist(widget.movieId);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPressed() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _isError = false;
    });

    try {
      await widget.provider.toggleWatchlist(widget.movieId, context);
      setState(() {
        _isAdded = widget.provider.isMovieInWatchlist(widget.movieId);
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isError = true;
        _isLoading = false;
      });
    }

    _controller.forward().then((_) => _controller.reverse());
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 360.w,
          height: 50.h,
          decoration: BoxDecoration(
            color: _isAdded
                ? Colors.green
                : (_isError ? Colors.red : Colors.white),
            borderRadius: BorderRadius.circular(25.r),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(25.r),
              onTap: _onPressed,
              child: Center(
                child: _isLoading
                    ? SizedBox(
                        width: 24.w,
                        height: 24.h,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _isError ? Colors.white : Colors.black,
                          ),
                        ),
                      )
                    : Text(
                        _isAdded
                            ? "Remove from Watchlist"
                            : (_isError
                                ? "Error Updating"
                                : "Add to Watchlist"),
                        style: TextStyle(
                            color: _isAdded || _isError
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontFamily: AppStrings.poppins,
                            fontSize: 16.sp),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
