import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class YourLoadingWidget extends StatelessWidget {
  final Widget child;
  const YourLoadingWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context ) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[500]!,
      child: Container(
        height: 620.h,
        padding: const EdgeInsets.only(top: 60),
        child: CarouselSlider(
          options: CarouselOptions(
            height: 420.h,
            viewportFraction: 0.8,
            enlargeCenterPage: true,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 2),
            enlargeStrategy: CenterPageEnlargeStrategy.scale,
            enableInfiniteScroll: true,
          ),
          items: List.generate(3, (index) {
            return Container(
              margin: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: child,
            );
          }),
        ),
      ),
    );
  }
}

